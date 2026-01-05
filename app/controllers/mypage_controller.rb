class MypageController < ApplicationController
  before_action :authenticate_user!

  def show
    favorite_event_records = current_user.favorites
      .where(favoritable_type: "Event")
      .includes(favoritable: { shop: :user })
      .order(created_at: :desc)

    @favorite_events = favorite_event_records.map(&:favoritable)

    @favorites_by_event_id = favorite_event_records.index_by(&:favoritable_id)

    favorite_shop_records = current_user.favorites
      .where(favoritable_type: "Shop")
      .includes(favoritable: :user)
      .order(created_at: :desc)

    @favorite_shops = favorite_shop_records.map(&:favoritable)
    @favorites_by_shop_id = favorite_shop_records.index_by(&:favoritable_id)

    @notification_settings = { email: true, push: false }
  end
end
