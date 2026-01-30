source "https://rubygems.org"

gem "rails", "~> 7.2.3"

# Server / DB
gem "puma", ">= 5.0"
gem "pg", "~> 1.1"

# Assets / Frontend
gem "sprockets-rails"
gem "jsbundling-rails"
gem "cssbundling-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "sassc-rails"

# Auth
gem "bcrypt", "~> 3.1.7"
gem "devise"
gem "devise-i18n"

# Storage / Upload
gem "image_processing", "~> 1.2"
gem "active_storage_validations"
gem "aws-sdk-s3", require: false

# App features
gem "ransack"
gem "kaminari"
gem "whenever", require: false
gem "rails_admin"
gem "cancancan"

# Platform
gem "bootsnap", require: false
gem "tzinfo-data", platforms: %i[windows jruby]

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "brakeman", require: false

  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"

  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
  gem "letter_opener_web"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "shoulda-matchers", "~> 6.0"
end