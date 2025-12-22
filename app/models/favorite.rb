class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :favoritable, polymorphic: true

  validates :user_id, uniqueness: { scope: [ :favoritable_type, :favoritable_id ] }
end
