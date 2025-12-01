class Shop < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, length: { maximum: 100 }
  validates :postal_code, length: { maximum: 10 }, allow_blank: true
  validates :phone_number, length: { maximum: 20 }, allow_blank: true
end
