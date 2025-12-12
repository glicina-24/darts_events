class Shop < ApplicationRecord
  belongs_to :user

  has_many :events, dependent: :destroy
  has_many_attached :images

  validates :name, presence: true, length: { maximum: 100 }
  validates :address, length: { maximum: 255 }, allow_blank: true
  validates :prefecture, length: { maximum: 50 }, allow_blank: true
  validates :city, length: { maximum: 100 }, allow_blank: true

  validates :postal_code, format: { with: /\A\d{3}-?\d{4}\z/ }, allow_blank: true
  validates :phone_number, format: { with: /\A\d{2,4}-?\d{2,4}-?\d{3,4}\z/ }, allow_blank: true

  scope :recent, -> { order(created_at: :desc) }

  def owned_by?(user)
    self.user == user
  end
end
