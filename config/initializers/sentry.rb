Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.environment = ENV.fetch("SENTRY_ENVIRONMENT", Rails.env)
  config.breadcrumbs_logger = %i[active_support_logger http_logger]
  config.enabled_environments = %w[production]
end
