class EmailDelivery < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :actor, class_name: "User", optional: true

  belongs_to :notifiable, polymorphic: true

  enum :status, { sent: "sent", failed: "failed" }

  validates :dedupe_key, presence: true, uniqueness: true
end
