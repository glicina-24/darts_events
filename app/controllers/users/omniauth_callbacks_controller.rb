class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    auth = request.env["omniauth.auth"]

    user = User.find_by(provider: auth.provider, uid: auth.uid)

    if user.nil?
      user = User.find_or_initialize_by(email: auth.info.email)
      user.provider = auth.provider
      user.uid = auth.uid
      user.name ||= auth.info.name
      user.password = Devise.friendly_token[0, 20] if user.encrypted_password.blank?
      user.skip_confirmation! if user.respond_to?(:skip_confirmation!)
      user.save!
    end

    sign_in_and_redirect user, event: :authentication
    set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
  end

  def failure
    redirect_to new_user_session_path, alert: "Googleログインに失敗しました。"
  end
end
