require "rails_helper"

RSpec.describe PushNotifications::SendService, type: :service do
  let(:user) { create(:user) }
  let!(:subscription) do
    create(
      :push_subscription,
      user: user,
      endpoint: "https://example.push.endpoint/send-service",
      p256dh: "test_p256dh",
      auth: "test_auth"
    )
  end
  let(:payload) { { title: "title", body: "body", url: "/events/1", tag: "event-1" } }

  describe ".call" do
    it "正常時は :ok を返す" do
      allow(WebPush).to receive(:payload_send).and_return(true)

      result = described_class.call(subscription: subscription, payload: payload)

      expect(result).to eq(:ok)
      expect(WebPush).to have_received(:payload_send).with(
        hash_including(
          message: payload.to_json,
          endpoint: subscription.endpoint,
          p256dh: subscription.p256dh,
          auth: subscription.auth,
          vapid: hash_including(:subject, :public_key, :private_key)
        )
      )
    end

    it "ExpiredSubscription発生時は購読を削除して :stale_deleted を返す" do
      stub_const("WebPush::ExpiredSubscription", Class.new(StandardError))
      allow(WebPush).to receive(:payload_send).and_raise(WebPush::ExpiredSubscription, "expired")

      result = nil
      expect {
        result = described_class.call(subscription: subscription, payload: payload)
      }.to change(PushSubscription, :count).by(-1)

      expect(result).to eq(:stale_deleted)
    end

    it "InvalidSubscription発生時は購読を削除して :stale_deleted を返す" do
      stub_const("WebPush::InvalidSubscription", Class.new(StandardError))
      allow(WebPush).to receive(:payload_send).and_raise(WebPush::InvalidSubscription, "invalid")

      result = nil
      expect {
        result = described_class.call(subscription: subscription, payload: payload)
      }.to change(PushSubscription, :count).by(-1)

      expect(result).to eq(:stale_deleted)
    end

    context "ResponseError のとき" do
      let(:response_error_class) do
        Class.new(StandardError) do
          attr_reader :response

          def initialize(status)
            @response = Struct.new(:status).new(status)
            super("response error")
          end
        end
      end

      before do
        stub_const("WebPush::ResponseError", response_error_class)
      end

      it "HTTP 404 は購読を削除して :stale_deleted を返す" do
        allow(WebPush).to receive(:payload_send).and_raise(WebPush::ResponseError.new(404))

        result = nil
        expect {
          result = described_class.call(subscription: subscription, payload: payload)
        }.to change(PushSubscription, :count).by(-1)

        expect(result).to eq(:stale_deleted)
      end

      it "HTTP 410 は購読を削除して :stale_deleted を返す" do
        allow(WebPush).to receive(:payload_send).and_raise(WebPush::ResponseError.new(410))

        result = nil
        expect {
          result = described_class.call(subscription: subscription, payload: payload)
        }.to change(PushSubscription, :count).by(-1)

        expect(result).to eq(:stale_deleted)
      end

      it "HTTP 500 は例外を再送出し、購読は削除しない" do
        allow(WebPush).to receive(:payload_send).and_raise(WebPush::ResponseError.new(500))

        expect {
          described_class.call(subscription: subscription, payload: payload)
        }.to raise_error(WebPush::ResponseError)
        expect(PushSubscription.exists?(subscription.id)).to be(true)
      end
    end
  end
end
