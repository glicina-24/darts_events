class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true

  scope :shop_owners, -> { where(shop_owner: true) }
  scope :pro_players, -> { where(pro_player: true) }
end
