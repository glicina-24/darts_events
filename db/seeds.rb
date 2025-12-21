require "faker"

puts "Seeding start..."

Faker::Config.locale = :ja

# オーナーユーザー
owner = User.find_or_create_by!(email: "owner@example.com") do |u|
  u.name = Faker::Name.name
  u.password = "password"
  u.password_confirmation = "password"
end

# 店舗
shops = 5.times.map do
  Shop.create!(
    user: owner,
    name: Faker::Company.name,
    prefecture: Faker::Address.state,
    city: Faker::Address.city,
    address: Faker::Address.street_address,
    phone_number: "0#{rand(70..90)}#{rand(10000000..99999999)}",
    description: Faker::Lorem.paragraph(sentence_count: 3)
  )
end

# イベント（50件）
50.times do
  shop = shops.sample
  start_at = Faker::Time.forward(days: 30, period: :day)

  Event.create!(
    shop: shop,
    title: Faker::Lorem.sentence(word_count: 5),
    description: Faker::Lorem.paragraphs(number: 3).join("\n"),
    start_datetime: start_at,
    end_datetime: start_at + rand(2..5).hours,
    location: shop.name,
    prefecture: shop.prefecture,
    city: shop.city,
    fee: [ 1000, 2000, 3000, 4000 ].sample,
    capacity: [ 16, 24, 32, nil ].sample,
    entry_deadline: start_at - rand(1..5).days,
    status: :scheduled
  )
end

puts "Seeding done!"
