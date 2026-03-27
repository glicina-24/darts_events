require "rails_helper"

RSpec.describe "Events create permission", type: :request do
  let(:user) { create(:user) }
  let(:alert_message) { "イベント投稿には店舗登録が必要です。先に店舗を登録してください。" }

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

  before { sign_in user }

  describe "GET /events/new" do
    context "approved店舗があるとき" do
      before do
        create(:shop, user: user, shop_status: :approved)
      end

      it "表示できる" do
        get new_event_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "pending店舗しかないとき" do
      before do
        create(:shop, user: user, shop_status: :pending)
      end

      it "リダイレクトされ、alertが表示される" do
        get new_event_path
        expect(response).to redirect_to(new_shop_path)
        expect(flash[:alert]).to eq(alert_message)
      end
    end

    context "rejected店舗しかないとき" do
      before do
        create(:shop, user: user, shop_status: :rejected)
      end

      it "リダイレクトされ、alertが表示される" do
        get new_event_path
        expect(response).to redirect_to(new_shop_path)
        expect(flash[:alert]).to eq(alert_message)
      end
    end
  end

  describe "POST /events" do
    context "approved店舗があるとき" do
      let!(:approved_shop) { create(:shop, user: user, shop_status: :approved) }

      it "イベントを作成して詳細へリダイレクトする" do
        expect {
          post events_path, params: event_params(shop_id: approved_shop.id)
        }.to change(Event, :count).by(1)

        event = Event.order(:id).last
        expect(response).to redirect_to(event_path(event))
        expect(event.shop).to eq(approved_shop)
      end
    end

    context "pending店舗しかないとき" do
      let!(:pending_shop) { create(:shop, user: user, shop_status: :pending) }

      it "作成できずリダイレクトされる" do
        expect {
          post events_path, params: event_params(shop_id: pending_shop.id)
        }.not_to change(Event, :count)

        expect(response).to redirect_to(new_shop_path)
        expect(flash[:alert]).to eq(alert_message)
      end
    end

    context "rejected店舗しかないとき" do
      let!(:rejected_shop) { create(:shop, user: user, shop_status: :rejected) }

      it "作成できずリダイレクトされる" do
        expect {
          post events_path, params: event_params(shop_id: rejected_shop.id)
        }.not_to change(Event, :count)

        expect(response).to redirect_to(new_shop_path)
        expect(flash[:alert]).to eq(alert_message)
      end
    end
  end
end
