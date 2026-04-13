require "rails_helper"

RSpec.describe "Push subscriptions", type: :request do
  let(:user) { create(:user) }

  describe "未ログイン" do
    let(:params) do
      {
        push_subscription: {
          endpoint: "https://example.push.endpoint/abc",
          p256dh: "p256dh_key",
          auth: "auth_key"
        }
      }
    end
    it "createできずログイン画面へリダイレクトされる" do
      expect {
        post push_subscription_path, params: params
      }.not_to change(PushSubscription, :count)

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_path)
    end
  end
  describe "POST /push_subscription" do
    before { sign_in user }

    let(:params) do
      {
        push_subscription: {
          endpoint: "https://example.push.endpoint/abc",
          p256dh: "p256dh_key",
          auth: "auth_key",
          user_agent: "RSpec"
        }
      }
    end

    it "初回のPush購読を登録できる" do
      expect {
        post push_subscription_path, params: params
      }.to change(PushSubscription, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(PushSubscription.last.user).to eq(user)
    end

    it "同じendpointで再登録したとき重複作成しない" do
      create(:push_subscription, user: user, endpoint: params[:push_subscription][:endpoint])

      expect {
        post push_subscription_path, params: params
      }.not_to change(PushSubscription, :count)

      expect(response).to have_http_status(:ok)
    end

    it "他ユーザーが所有するendpointを再登録すると409を返し、所有者を変えない" do
      other_user = create(:user)
      existing = create(
        :push_subscription,
        user: other_user,
        endpoint: params[:push_subscription][:endpoint],
        p256dh: "old_p256dh",
        auth: "old_auth"
      )

      expect {
        post push_subscription_path, params: params
      }.not_to change(PushSubscription, :count)

      expect(response).to have_http_status(:conflict)

      existing.reload
      expect(existing.user).to eq(other_user)
      expect(existing.p256dh).to eq("old_p256dh")
      expect(existing.auth).to eq("old_auth")
    end
  end

  describe "DELETE /push_subscription" do
    before { sign_in user }

    it "ログインユーザーは自分のPush購読を解除できる" do
      subscription = create(:push_subscription, user: user, endpoint: "https://example.push.endpoint/delete-me")

      expect {
        delete push_subscription_path, params: { endpoint: subscription.endpoint }
      }.to change(PushSubscription, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
