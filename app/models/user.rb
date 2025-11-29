class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true

  enum shop_owner_status: { not_applying: 0, pending: 1, approved: 2, rejected: 3 }, _prefix: true
  enum pro_player_status:  { not_applying: 0, pending: 1, approved: 2, rejected: 3 }, _prefix: true

  # 実際に「オーナーとして扱っていいか？」の判定
  def shop_owner?
    shop_owner_status == "approved"
  end

  def pro_player?
    pro_player_status == "approved"
  end
end
