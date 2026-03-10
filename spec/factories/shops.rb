FactoryBot.define do
  factory :shop do
    association :user
    sequence(:name) { |n| "テスト店舗#{n}" }
    prefecture { "福岡県" }
    city { "福岡市" }
    google_maps_url { "https://www.google.com/maps" }
    contact_email { "shop@example.com" }
    shop_status { :pending }
  end
end
