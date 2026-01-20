class Event < ApplicationRecord
  belongs_to :shop
  has_many_attached :images

  validates :title, presence: true, length: { maximum: 80 }
  validates :start_datetime, presence: true
  validates :fee, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :capacity, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :images, content_type: %w[image/jpeg image/png image/webp], size: { less_than: 5.megabytes }, limit: { max: 5 }

  validates :location, length: { maximum: 80 }, allow_blank: true
  validates :prefecture, length: { maximum: 20 }, allow_blank: true
  validates :city, length: { maximum: 50 }, allow_blank: true
  validates :address, length: { maximum: 200 }, allow_blank: true
  validates :description, length: { maximum: 2000 }, allow_blank: true
  validates :latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, allow_nil: true
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_nil: true

  validate :end_after_start
  validate :deadline_before_start

  has_many :event_participants, dependent: :destroy
  has_many :pro_players, through: :event_participants, source: :user
  has_many :favorites, as: :favoritable, dependent: :destroy

  delegate :name, to: :shop, prefix: true
  delegate :prefecture, to: :shop, prefix: true, allow_nil: true

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
    %w[shop pro_players event_participants]
  end

  def status_i18n
    I18n.t("enums.event.status.#{status}", default: status)
  end

  def favorited_by?(user)
    return false unless user
    favorites.exists?(user_id: user.id)
  end

  enum :status, { scheduled: 0, finished: 1, canceled: 2 }, default: :scheduled

  scope :should_be_finished, -> {
    where(status: :scheduled)
      .where(
        "(end_datetime IS NOT NULL AND end_datetime < :now) OR
        (end_datetime IS NULL AND start_datetime < :now)",
        now: Time.current
      )
  }

  def self.finish_past_events!
    should_be_finished.update_all(
      status: statuses[:finished],
      updated_at: Time.current
    )
  end

  def pro_players_display
    pro_player_names = pro_players.map(&:name).reject(&:blank?)
    return "ゲストなし" if pro_player_names.empty?
    pro_player_names.map { |n| "#{n}プロ" }.join(", ")
  end

  private

  def end_after_start
    return if start_datetime.blank? || end_datetime.blank?
    errors.add(:end_datetime, "は開始日時より後にしてください") if end_datetime <= start_datetime
  end

  def deadline_before_start
    return if entry_deadline.blank? || start_datetime.blank?
    errors.add(:entry_deadline, "は開始日時より前にしてください") if entry_deadline >= start_datetime
  end
end
