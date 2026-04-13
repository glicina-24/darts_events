class PushNotificationJob < ApplicationJob
  queue_as :default
  # 購読解除済みなどでレコードが消えていたら静かに終了
  discard_on ActiveRecord::RecordNotFound

  def perform(push_subscription_id, payload)
    subscription = PushSubscription.find(push_subscription_id)
    PushNotifications::SendService.call(subscription:, payload:)
  end
end
