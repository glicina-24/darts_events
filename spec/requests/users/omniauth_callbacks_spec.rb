require "rails_helper"

RSpec.describe "Users::OmniauthCallbacks", type: :request do
  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    OmniAuth.config.test_mode = false
  end

  describe "POST /users/auth/google_oauth2/callback" do
    it "ユーザーを新規作成してログインする" do
      OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: "987654321",
        info: {
          email: "new-user@example.com",
          name: "新規ユーザー"
        }
      )

      expect {
        get user_google_oauth2_omniauth_callback_path
      }.to change(User, :count).by(1)

      user = User.find_by(email: "new-user@example.com")
      expect(user.provider).to eq("google_oauth2")
      expect(user.uid).to eq("987654321")
      expect(response).to redirect_to(root_path)
    end
    it "既存ユーザーにGoogle連携情報を保存してログインする" do
      user = create(:user, email: "test@example.com")

      OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: "123456789",
        info: {
          email: "test@example.com",
          name: "テストユーザー"
        }
      )

      post user_google_oauth2_omniauth_callback_path

      user.reload
      expect(user.provider).to eq("google_oauth2")
      expect(user.uid).to eq("123456789")
      expect(response).to redirect_to(root_path)
    end
  end
end
