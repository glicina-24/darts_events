require "rails_helper"

RSpec.describe Event, type: :model do
  describe "images validation" do
    let(:owner) { create(:user) }
    let(:shop)  { create(:shop, user: owner) }
    let(:event) { build(:event, shop: shop) }
    let(:file_path) { Rails.root.join("spec/fixtures/files/sample.jpeg") }

    def attach_jpg(times)
      times.times do
        event.images.attach(
          io: File.open(file_path),
          filename: "sample.jpeg",
          content_type: "image/jpeg"
        )
      end
    end

    it "画像が6枚以上だと無効（最大5枚）" do
      attach_jpg(6)

      expect(event).not_to be_valid
      expect(event.errors[:images]).to be_present
      expect(event.errors[:images].join).to match(/5/)
    end

    it "画像が5枚までなら有効" do
      attach_jpg(5)

      expect(event).to be_valid
    end
  end
end
