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
end
