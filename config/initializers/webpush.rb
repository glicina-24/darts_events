Rails.application.configure do
  config.x.webpush = ActiveSupport::OrderedOptions.new
  config.x.webpush.public_key  = ENV["VAPID_PUBLIC_KEY"]
  config.x.webpush.private_key = ENV["VAPID_PRIVATE_KEY"]
  config.x.webpush.subject     = ENV["VAPID_SUBJECT"] # 例: mailto:admin@example.com
end
