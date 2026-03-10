require "rails_helper"

RSpec.describe "Shops", type: :request do
  describe "GET /shops/:id/verify_email" do
    it "正しいトークンならメール確認完了になる" do
      shop = create(:shop, shop_status: :pending)
      raw_token = shop.generate_email_verification_token!

      get verify_email_shop_path(shop, token: raw_token)

      shop.reload
      expect(response).to redirect_to(shops_path)
      expect(shop.email_verified_at).to be_present
      expect(shop.email_verification_token_digest).to be_nil
    end
  end
end
