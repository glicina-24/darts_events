require "rails_helper"

RSpec.describe Notifications::EventNotificationService, type: :service do
  let(:actor) { create(:user) }
  let(:owner) { create(:user) }
  let(:shop)  { create(:shop, user: owner) }
  let(:event) { create(:event, shop: shop) }
  let(:recipient) { create(:user) }

  let(:context) { { reasons: [], pro_names: [], shop_name: shop.name } }

  it "メール送信が例外でも落ちず :failed を返し、Sentryに送る" do
    service = described_class.new(event, actor: actor)

    allow(EventMailer).to receive_message_chain(:event_created, :deliver_later)
      .and_raise(StandardError.new("boom"))

    # Sentryがない環境でもテストが落ちないようにする
    stub_const("Sentry", Class.new) unless defined?(Sentry)
    allow(Sentry).to receive(:capture_exception)

    result = service.event_created!(recipient, context)

    expect(result).to eq(:failed)
    expect(Sentry).to have_received(:capture_exception)
  end
  describe "#notify_event_created!" do
    it "Push配信対象があるとき FanoutService を呼び出す" do
      service = described_class.new(event, actor: actor)
      recipients = { recipient.id => context }

      allow(service).to receive(:recipients_with_reason_for_event_created).and_return(recipients)
      allow(service).to receive(:event_created!).and_return(:sent)

      expect(PushNotifications::FanoutService).to receive(:call).with(
        user_ids: [ recipient.id ],
        payload: hash_including(
          title: "新しいイベントが投稿されました",
          body: "#{shop.name} / #{event.title}",
          url: Rails.application.routes.url_helpers.event_path(event),
          tag: "event-#{event.id}"
        )
      )

      service.notify_event_created!
    end

    it "Push enqueueで例外が起きても notify_event_created! は落ちない" do
      service = described_class.new(event, actor: actor)
      recipients = { recipient.id => context }

      allow(service).to receive(:recipients_with_reason_for_event_created).and_return(recipients)
      allow(service).to receive(:event_created!).and_return(:sent)
      allow(PushNotifications::FanoutService).to receive(:call).and_raise(StandardError, "push enqueue failed")
      allow(Rails.logger).to receive(:error)

      stub_const("Sentry", Class.new) unless defined?(Sentry)
      allow(Sentry).to receive(:capture_exception)

      expect { service.notify_event_created! }.not_to raise_error
      expect(Sentry).to have_received(:capture_exception)
    end
  end
end
