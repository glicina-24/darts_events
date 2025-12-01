class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true
  has_many :shops, dependent: :destroy
  has_many :events, through: :shops

  def shop_owner?
    shops.exists?
  end

  # ▼ イベント投稿などで利用:
  def approved_store_owner?
    shop_owner?
  end
end
