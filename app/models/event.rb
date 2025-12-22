class Event < ApplicationRecord
  belongs_to :shop
  has_many_attached :images

  has_many :event_participants, dependent: :destroy
  has_many :participants, through: :event_participants, source: :user
  has_many :favorites, as: :favoritable, dependent: :destroy

  delegate :name, to: :shop, prefix: true
  delegate :prefecture, to: :shop, prefix: true, allow_nil: true

  validates :images,
    content_type: %w[image/jpeg image/png image/webp],
    size: { less_than: 5.megabytes },
    limit: { max: 5 }

  enum status: { scheduled: 0, finished: 1, canceled: 2 }, _default: :scheduled

  def owned_by?(user)
    shop.user == user
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      title
      description
      start_datetime
      end_datetime
      prefecture
      city
      address
      location
      fee
      capacity
      entry_deadline
      status
      shop_id
      created_at
      updated_at
      id
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[shop participants event_participants]
  end

  def status_i18n
    I18n.t("enums.event.status.#{status}", default: status)
  end

  def favorited_by?(user)
    return false unless user
    favorites.exists?(user_id: user.id)
  end
end
