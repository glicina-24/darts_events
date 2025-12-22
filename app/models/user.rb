class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true
  has_many :shops, dependent: :destroy
  has_many :events, through: :shops
  has_many :event_participants, dependent: :destroy
  has_many :participating_events, through: :event_participants, source: :event
  has_many :favorites, dependent: :destroy

  def shop_owner?
    shops.exists?
  end

  def approved_store_owner?
    shop_owner?
  end

  scope :approved_pros, -> { where(pro_player_status: :approved) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[id name pro_player_status]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[event_participants participating_events]
  end
end
