class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true
  has_many :events, dependent: :destroy
  has_many :stores, dependent: :destroy

  enum :shop_owner_status,
  { not_applying: 0, pending: 1, approved: 2, rejected: 3 },
  prefix: true

  enum :pro_player_status,
  { not_applying: 0, pending: 1, approved: 2, rejected: 3 },
  prefix: true

  def shop_owner?
  shop_owner_status_approved?
  end

  def pro_player?
  pro_player_status_approved?
  end
  # Store 側でこんな enum 定義してる前提:
  # enum :status, { pending: 0, approved: 1, rejected: 2 }, prefix: true
  def approved_store_owner?
    stores.status_approved.exists?
  end
end
