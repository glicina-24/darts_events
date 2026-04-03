require "rails_helper"

RSpec.describe "Events confirm", type: :request do
  let(:owner) { create(:user) }
  let!(:shop) { create(:shop, user: owner, shop_status: :approved) }

  before { sign_in owner }

  describe "POST /events/confirm" do
    let(:params) do
      {
        event: {
          title: "確認テストイベント",
          shop_id: shop.id,
          start_datetime: 1.day.from_now,
          description: "確認画面のテスト"
        }
      }
    end

    it "イベントを保存せず確認画面を表示する" do
      expect do
        post confirm_events_path, params: params
      end.not_to change(Event, :count)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("投稿内容を確認する")
      expect(response.body).to include("この内容で投稿する")
    end

    context "自分の店舗ではないshop_idが指定されたとき" do
      let!(:other_owner) { create(:user) }
      let!(:other_shop)  { create(:shop, user: other_owner, shop_status: :approved) }

      let(:params) do
        {
          event: {
            title: "確認テストイベント",
            shop_id: other_shop.id,
            start_datetime: 1.day.from_now,
            description: "確認画面のテスト"
          }
        }
      end

      it "確認画面に進めず、newを422で再表示する" do
        expect do
          post confirm_events_path, params: params
        end.not_to change(Event, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("不正な店舗が指定されました。")
        expect(response.body).to include("確認画面へ")
        expect(response.body).not_to include("この内容で投稿する")
      end
    end
  end
end
