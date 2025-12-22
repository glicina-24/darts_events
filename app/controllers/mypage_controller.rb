class MypageController < ApplicationController
  before_action :authenticate_user!

  def show
    # N+1避け：イベントは shop まで使うので includes
    @favorite_events = current_user.favorites
      .where(favoritable_type: "Event")
      .includes(favoritable: { shop: :user })
      .order(created_at: :desc)
      .map(&:favoritable)

    @favorite_shops = current_user.favorites
      .where(favoritable_type: "Shop")
      .includes(favoritable: :user)
      .order(created_at: :desc)
      .map(&:favoritable)

    # 後で通知設定をDB化する用（今はダミー）
    @notification_settings = {
      email: true,
      push: false
    }
  end
end
