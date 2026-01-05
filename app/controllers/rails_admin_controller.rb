class RailsAdminController < ActionController::Base
  include Rails.application.routes.url_helpers

  protect_from_forgery with: :exception

  # Devise
  before_action :authenticate_user!
end
