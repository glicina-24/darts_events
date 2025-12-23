class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :actor, class_name: "User", optional: true
  belongs_to :notifiable, polymorphic: true

  scope :unread, -> { where(read_at: nil) }

  def message
    actor_name = actor&.name || "誰か"

    case [ action, notifiable_type ]
    when [ "favorited", "Event" ]
      "あなたのイベントが #{actor_name} にお気に入りされました"
    when [ "favorited", "Shop" ]
      "あなたの店舗が #{actor_name} にお気に入りされました"
    when [ "new_event", "Event" ]
      "お気に入りの店舗から新しいイベントが公開されました"
    else
      "通知があります"
    end
  end
end
