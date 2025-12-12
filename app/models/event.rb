class Event < ApplicationRecord
  belongs_to :shop
  has_many_attached :images

  validates :images,
    content_type: %w[image/jpeg image/png image/webp],
    size: { less_than: 5.megabytes },
    limit: { max: 5 }

  enum status: { scheduled: 0, finished: 1, canceled: 2 }, _default: :scheduled

  def owned_by?(user)
    shop.user == user
  end
end
