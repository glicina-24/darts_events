require "rails_helper"

RSpec.describe "Event favorites", type: :request do
  let(:user) { create(:user) }

  describe "POST /events/:event_id/favorite" do
    it "未ログインはログインへ" do
      event = create(:event)
      post event_favorite_path(event)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "ログイン済みはお気に入りできる（DB増える）" do
      event = create(:event)
      sign_in user
      expect {
        post event_favorite_path(event)
      }.to change(Favorite, :count).by(1)
      expect(response).to have_http_status(:found)
    end
  end

  describe "DELETE /events/:event_id/favorite" do
    it "ログイン済みは解除できる（DB減る）" do
      event = create(:event)
      sign_in user
      post event_favorite_path(event)
      expect {
        delete event_favorite_path(event)
      }.to change(Favorite, :count).by(-1)
      expect(response).to have_http_status(:found)
    end
  end
end
