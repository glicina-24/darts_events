class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true
  has_many :events, dependent: :destroy
  has_many :shops, dependent: :destroy

  # ▼ 現在の仕様：
  # 店舗が1件以上あれば「店舗オーナー」と扱う
  def shop_owner?
    shops.exists?
  end

  # ▼ イベント投稿などで利用:
  def approved_store_owner?
    shop_owner?
  end
end
