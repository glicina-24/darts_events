FactoryBot.define do
  factory :event do
    association :shop
    title { "テストイベント" }
    start_datetime { Time.zone.now + 1.day }
    description { "テスト用イベントです" }
  end
end
