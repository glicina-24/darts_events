class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  validates :name, presence: true
  has_many :shops, dependent: :destroy
  has_many :events, through: :shops
  has_many :event_participants, dependent: :destroy
  has_many :participating_events, through: :event_participants, source: :event
  has_many :favorites, dependent: :destroy

  has_many :received_notifications,
            class_name: "Notification",
            foreign_key: :recipient_id,
            dependent: :destroy

  enum :pro_player_status, { unapplied: 0, pending: 1, approved: 2, rejected: 3 }, default: :unapplied

  validates :pro_sns_url, presence: true, if: -> { pro_player_status == "pending" }

  def shop_owner?
    shops.exists?
  end

  def approved_store_owner?
    shop_owner?
  end

  scope :approved_pros, -> { where(pro_player_status: :approved) }
  # scope :pro_applicants, -> { where(pro_player_status: :pending) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[id name pro_player_status]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[event_participants participating_events]
  end

  enum :role, { general: 0, admin: 1 }, default: :general

  before_save :sync_pro_player_flag

  after_update_commit :notify_pro_approved, if: :saved_change_to_pro_player_status?

  private

  def sync_pro_player_flag
    self.pro_player = approved?
  end

  def notify_pro_approved
    return unless approved?

    Notification.create!(
      recipient: self,
      actor: nil,
      action: "pro_approved",
      notifiable: self
    )
  end
end
