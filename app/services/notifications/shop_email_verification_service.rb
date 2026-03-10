module Notifications
  class ShopEmailVerificationService
    def self.call(shop:, raw_token:)
      new(shop:, raw_token:).call
    end

    def initialize(shop:, raw_token:)
      @shop = shop
      @raw_token = raw_token
    end

    def call
      ShopMailer.email_verification(@shop, @raw_token).deliver_later
    end

    private

    attr_reader :shop, :raw_token
  end
end
