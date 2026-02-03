require "rails_helper"

RSpec.describe "Events authorization", type: :request do
  let(:owner) { create(:user) }
  let(:other) { create(:user) }

  # 店舗オーナー = owner のshop
  let(:shop) { create(:shop, user: owner) }

  # Eventは shop 必須（投稿者は shop.user が実質オーナー）
  let!(:event) { create(:event, shop: shop) }

  describe "GET /events/:id/edit" do
    it "未ログインはログインへ" do
      get edit_event_path(event)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "他人（店舗オーナー以外）は編集できない" do
      sign_in other
      get edit_event_path(event)
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(event_path(event))
    end

    it "本人（店舗オーナー）は編集できる" do
      sign_in owner
      get edit_event_path(event)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /events/:id" do
    it "他人（店舗オーナー以外）は更新できずDB変更なし" do
      sign_in other
      before_title = event.title # titleが無いなら別カラムに変更

      patch event_path(event), params: { event: { title: "updated" } }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(event_path(event))
      expect(event.reload.title).to eq(before_title)
    end

    it "本人（店舗オーナー）は更新できる" do
      sign_in owner

      patch event_path(event), params: { event: { title: "updated" } }

      expect(response).to have_http_status(:found)
      expect(event.reload.title).to eq("updated")
    end
  end

  describe "DELETE /events/:id" do
    it "他人（店舗オーナー以外）は削除できずDB変更なし" do
      sign_in other

      expect {
        delete event_path(event)
      }.not_to change(Event, :count)

      expect(response).to redirect_to(event_path(event))
    end

    it "本人（店舗オーナー）は削除できる" do
      sign_in owner

      expect {
        delete event_path(event)
      }.to change(Event, :count).by(-1)

      expect(response).to have_http_status(:see_other)
    end
  end
end