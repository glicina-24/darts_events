class Event < ApplicationRecord
  belongs_to :shop
  has_many_attached :images

  enum status: { scheduled: 0, finished: 1, canceled: 2 }, _default: :scheduled

  def owned_by?(user)
    shop.user == user
  end
end
