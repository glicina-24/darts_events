require "rails_helper"

RSpec.describe "Events create permission", type: :request do
  let(:user) { create(:user) }

  def event_params(shop_id:)
    {
      event: {
        title: "新規イベント",
        shop_id: shop_id,
        start_datetime: 1.day.from_now,
        description: "テスト投稿"
      }
    }
  end

  describe "GET /events/new" do
    it "approved店舗があるユーザーは表示できる" do
      create(:shop, user: user, shop_status: :approved)
      sign_in user

      get new_event_path

      expect(response).to have_http_status(:ok)
    end

    it "pending店舗しかないユーザーは表示できない" do
      create(:shop, user: user, shop_status: :pending)
      sign_in user

      get new_event_path

      expect(response).to redirect_to(new_shop_path)
    end

    it "rejected店舗しかないユーザーは表示できない" do
      create(:shop, user: user, shop_status: :rejected)
      sign_in user

      get new_event_path

      expect(response).to redirect_to(new_shop_path)
    end
  end

  describe "POST /events" do
    it "approved店舗なら作成できる" do
      approved_shop = create(:shop, user: user, shop_status: :approved)
      sign_in user

      expect {
        post events_path, params: event_params(shop_id: approved_shop.id)
      }.to change(Event, :count).by(1)

      expect(response).to have_http_status(:found)
      expect(Event.last.shop).to eq(approved_shop)
    end

    it "pending店舗しかないユーザーは作成できない" do
      pending_shop = create(:shop, user: user, shop_status: :pending)
      sign_in user

      expect {
        post events_path, params: event_params(shop_id: pending_shop.id)
      }.not_to change(Event, :count)

      expect(response).to redirect_to(new_shop_path)
    end

    it "rejected店舗しかないユーザーは作成できない" do
      rejected_shop = create(:shop, user: user, shop_status: :rejected)
      sign_in user

      expect {
        post events_path, params: event_params(shop_id: rejected_shop.id)
      }.not_to change(Event, :count)

      expect(response).to redirect_to(new_shop_path)
    end
  end
end
