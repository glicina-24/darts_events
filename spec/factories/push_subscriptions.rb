FactoryBot.define do
  factory :push_subscription do
    user { nil }
    endpoint { "MyText" }
    p256dh { "MyString" }
    auth { "MyString" }
    expiration_time { "2026-04-05 07:53:45" }
    user_agent { "MyString" }
  end
end
