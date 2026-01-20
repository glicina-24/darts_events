puts "Seeding start..."

owner = User.find_or_create_by!(email: "owner@example.com") do |u|
  u.name = "店舗オーナー"
  u.password = "password"
  u.password_confirmation = "password"
  u.shop_owner = true
end

pro = User.find_or_create_by!(email: "pro@example.com") do |u|
  u.name = "プロプレイヤー"
  u.password = "password"
  u.password_confirmation = "password"
  u.pro_sns_url = "https://x.com/example"
  u.pro_applied_at = Time.current - 2.days
  u.pro_player_status = :approved
end

10.times do
  email = Faker::Internet.unique.email
  User.find_or_create_by!(email: email) do |u|
    u.name = Faker::Name.name
    u.password = "password"
    u.password_confirmation = "password"
    u.pro_sns_url = Faker::Internet.url(host: "example.com")
    u.pro_applied_at = Time.current - rand(1..14).days
    u.pro_player_status = :approved
  end
end

general = User.find_or_create_by!(email: "general@example.com") do |u|
  u.name = "一般ユーザー"
  u.password = "password"
  u.password_confirmation = "password"
end

shop = Shop.find_or_create_by!(name: "Darts Bar ONE", user: owner) do |s|
  s.description = "初心者歓迎のダーツバー"
  s.prefecture = "宮崎県"
  s.city = "宮崎市"
  s.address = "宮崎県宮崎市〇〇1-2-3"
end

event = Event.find_or_create_by!(
  shop: shop,
  title: "ハウストーナメント（初心者歓迎）",
  start_datetime: Time.current + 7.days
) do |e|
  e.description = "レーティング不問。楽しくやるイベントです。"
  e.end_datetime = e.start_datetime + 3.hours
  e.entry_deadline = e.start_datetime - 1.day
  e.capacity = 32
  e.fee = 1000
  e.status = :scheduled
end

EventParticipant.find_or_create_by!(event: event, user: pro)

Favorite.find_or_create_by!(user: general, favoritable: shop)

Notification.find_or_create_by!(
  recipient: general,
  action: "new_event",
  notifiable: event)

puts "Seeding done!"
