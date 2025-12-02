class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :hide_flash_on_some_pages

  protected

  def configure_permitted_parameters
    added_attrs = [
      :name,
      :shop_owner_status,
      :pro_player_status
    ]

    devise_parameter_sanitizer.permit(:sign_up, keys: added_attrs)
    devise_parameter_sanitizer.permit(:account_update, keys: added_attrs)
  end

    private

  def hide_flash_on_some_pages
    if devise_controller? && controller_name == "sessions" && action_name == "new"
      @disable_flash = true
    end
  end
end
