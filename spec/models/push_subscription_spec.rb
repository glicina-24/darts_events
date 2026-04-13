require "rails_helper"

RSpec.describe PushSubscription, type: :model do
  let(:user) { create(:user) }

  subject(:push_subscription) { build(:push_subscription, user: user) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:endpoint) }
    it { is_expected.to validate_presence_of(:p256dh) }
    it { is_expected.to validate_presence_of(:auth) }

    it "validates uniqueness of endpoint" do
      create(:push_subscription, user: user, endpoint: "https://example.push.endpoint/unique")
      duplicate = build(:push_subscription, user: create(:user), endpoint: "https://example.push.endpoint/unique")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors.of_kind?(:endpoint, :taken)).to be(true)
    end
  end
end
