FactoryBot.define do
  factory :shop do
    association :user
    sequence(:name) { |n| "テスト店舗#{n}" }
    prefecture { "福岡県" }
    city { "福岡市" }
  end
end
