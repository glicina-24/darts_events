require "rails_helper"

RSpec.describe "Event image destroy", type: :request do
  let(:owner) { create(:user) }
  let(:other) { create(:user) }
  let(:shop) { create(:shop, user: owner) }
  let!(:event) { create(:event, shop: shop) }
  let!(:attachment) do #画像
    event.images.attach(
      io: File.open(Rails.root.join("spec/fixtures/files/sample.jpeg")),
      filename: "sample.jpeg",
      content_type: "image/jpeg"
    )
    event.images.attachments.last
  end

  describe "DELETE /events/:id/images/:image_id" do
    it "未ログインはログインへリダイレクト" do
      delete image_event_path(event, image_id: attachment.id)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "他人（店舗オーナー以外）は削除できずattachment数が減らない" do
      sign_in other

      expect {
        delete image_event_path(event, image_id: attachment.id)
      }.not_to change { event.images.attachments.count }

      expect(response).to have_http_status(:not_found)
    end

    it "本人（店舗オーナー）は削除できてattachment数が1減る" do
      sign_in owner

      expect {
        delete image_event_path(event, image_id: attachment.id)
      }.to change { event.images.attachments.count }.by(-1)

      expect(response).to be_redirect
    end
  end
end