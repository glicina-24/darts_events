require "rails_helper"

RSpec.describe "Events images validation", type: :request do
  let(:owner) { create(:user) }
  let(:shop)  { create(:shop, user: owner) }

  let(:file_path) { Rails.root.join("spec/fixtures/files/sample.jpeg") }

  def upload_file
    Rack::Test::UploadedFile.new(file_path, "image/jpeg")
  end

  it "画像が6枚以上だと作成できず422" do
    sign_in owner

    params = {
      event: {
        title: "test",
        shop_id: shop.id,
        images: Array.new(6) { upload_file }
      }
    }

    post events_path, params: params

    expect(response).to have_http_status(:unprocessable_entity)
  end
end
