require "rails_helper"

RSpec.describe Shop, type: :model do
  describe "#generate_email_verification_token!" do
    it "トークンを発行し、digestと送信時刻を保存する" do
      shop = create(:shop)

      raw_token = shop.generate_email_verification_token!
      shop.reload

      expect(raw_token).to be_present
      expect(shop.email_verification_token_digest).to be_present
      expect(shop.email_verification_sent_at).to be_present
      expect(shop.email_verified_at).to be_nil
    end
  end

  describe "#email_verification_token_valid?" do
    it "正しいトークンならtrueを返す" do
      shop = create(:shop)
      raw_token = shop.generate_email_verification_token!

      expect(shop.email_verification_token_valid?(raw_token)).to be true
    end
  end

  describe "#mark_email_verified!" do
    it "メール確認済みにし、digestをnilにする" do
      shop = create(:shop)
      shop.generate_email_verification_token!

      shop.mark_email_verified!
      shop.reload

      expect(shop.email_verified_at).to be_present
      expect(shop.email_verification_token_digest).to be_nil
    end
  end
end
