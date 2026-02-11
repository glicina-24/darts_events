require "rails_helper"

RSpec.describe "Confirmable authentication", type: :request do
  let(:password) { "password123" }

  it "未認証ユーザーはログインできない" do
    user = create(:user, password:, password_confirmation: password, confirmed_at: nil)
    post user_session_path, params: {
      user: { email: user.email, password: }
    }
    expect(response).to redirect_to(new_user_session_path)
  end

  it "認証済みユーザーはログインできる" do
    user = create(:user, password:, password_confirmation: password, confirmed_at: Time.current)

    post user_session_path, params: {
      user: { email: user.email, password: }
    }

    expect(response).to redirect_to(root_path)
  end
end
