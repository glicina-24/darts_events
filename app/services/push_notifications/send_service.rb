module PushNotifications
  class SendService
    def self.call(subscription:, payload:)
      new(subscription:, payload:).call
    end

    def initialize(subscription:, payload:)
      @subscription = subscription
      @payload = payload
    end

    def call
      Webpush.payload_send(
        message: payload.to_json,
        endpoint: subscription.endpoint,
        p256dh: subscription.p256dh,
        auth: subscription.auth,
        vapid: {
          subject: Rails.configuration.x.webpush.subject,
          public_key: Rails.configuration.x.webpush.public_key,
          private_key: Rails.configuration.x.webpush.private_key
        }
      )
      :ok
    rescue Webpush::ExpiredSubscription, Webpush::InvalidSubscription
      subscription.destroy!
      :stale_deleted
    rescue Webpush::ResponseError => e
      # gemバージョン差があるので status 取得は実ログで確認して調整
      status = e.respond_to?(:response) ? e.response&.status.to_i : nil
      if [ 404, 410 ].include?(status)
        subscription.destroy!
        :stale_deleted
      else
        raise
      end
    end

    private

    attr_reader :subscription, :payload
  end
end
