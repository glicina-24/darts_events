class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :favoritable, polymorphic: true

  validates :user_id, uniqueness: { scope: [ :favoritable_type, :favoritable_id ] }

  after_create_commit :notify_recipient!

  private

  def notify_recipient!
    recipient =
      case favoritable
      when Event
        favoritable.shop&.user
      when Shop
        favoritable.user
      end

    return if recipient.blank?
    return if recipient == user # 自分の店/イベントをお気に入りしても通知いらん

    Notification.create!(
      recipient: recipient,
      actor: user,
      action: "favorited",
      notifiable: favoritable
    )
  end
end
