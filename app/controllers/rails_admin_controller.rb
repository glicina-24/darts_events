class RailsAdminController < ActionController::Base
  include Rails.application.routes.url_helpers

  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :require_admin!

  private

  def require_admin!
    return if current_user&.admin?

    redirect_to main_app.root_path, alert: "権限がありません"
  end
end
