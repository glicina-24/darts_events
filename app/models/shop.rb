class Shop < ApplicationRecord
  belongs_to :user

  has_many :events, dependent: :destroy
  has_many :favorites, as: :favoritable, dependent: :destroy

  has_many_attached :images

  validates :images, content_type: %w[image/jpeg image/png image/webp], size: { less_than: 5.megabytes }, limit: { max: 5 }

  validates :name, presence: true, length: { maximum: 100 }
  validates :address, length: { maximum: 255 }, allow_blank: true
  validates :prefecture, length: { maximum: 50 }, allow_blank: true
  validates :city, length: { maximum: 100 }, allow_blank: true

  validates :postal_code, format: { with: /\A\d{3}-?\d{4}\z/ }, allow_blank: true
  validates :phone_number, format: { with: /\A\d{2,4}-?\d{2,4}-?\d{3,4}\z/ }, allow_blank: true

  enum :shop_status, { pending: 0, approved: 1, rejected: 2 }

  validates :google_maps_url, presence: true, if: :pending?
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }, presence: true, if: :pending?

  scope :recent, -> { order(created_at: :desc) }
  scope :visible, -> { approved }

  def owned_by?(user)
    self.user == user
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[name prefecture city address]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user events]
  end

  def favorited_by?(user)
    return false unless user
    favorites.exists?(user_id: user.id)
  end

  def email_verified?
    email_verified_at.present?
  end

  def generate_email_verification_token!
    raw_token = SecureRandom.urlsafe_base64(32)
    digest = Digest::SHA256.hexdigest(raw_token)

    update!(
      email_verification_token_digest: digest,
      email_verification_sent_at: Time.current,
      email_verified_at: nil
    )

    raw_token
  end

  def email_verification_token_valid?(raw_token)
    return false if raw_token.blank?
    return false if email_verification_token_digest.blank?
    return false if email_verification_sent_at.blank?
    return false if email_verification_sent_at < 24.hours.ago

    digest = Digest::SHA256.hexdigest(raw_token)

    ActiveSupport::SecurityUtils.secure_compare(
      email_verification_token_digest,
      digest
    )
  end

  def mark_email_verified!
    update!(
      email_verified_at: Time.current,
      email_verification_token_digest: nil
    )
  end
end
