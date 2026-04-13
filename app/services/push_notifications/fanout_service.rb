module PushNotifications
  class FanoutService
    def self.call(user_ids:, payload:)
      new(user_ids:, payload:).call
    end

    def initialize(user_ids:, payload:)
      @user_ids = user_ids
      @payload = payload
    end

    def call
      PushSubscription.where(user_id: user_ids).find_each do |subscription|
        PushNotificationJob.perform_later(subscription.id, payload)
      end
    end

    private

    attr_reader :user_ids, :payload
  end
end
