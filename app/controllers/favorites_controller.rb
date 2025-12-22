class FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_favoritable

  def create
    favorite = current_user.favorites.find_or_create_by!(favoritable: @favoritable)

    create_favorite_notification!(@favoritable)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          helpers.dom_id(@favoritable, :favorite_button),
          partial: "favorites/button",
          locals: { favoritable: @favoritable, favorite: favorite }
        )
      end
      format.html { redirect_back fallback_location: root_path, notice: "お気に入りに追加しました。" }
    end
  end

  def destroy
    current_user.favorites.where(favoritable: @favoritable).destroy_all

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          helpers.dom_id(@favoritable, :favorite_button),
          partial: "favorites/button",
          locals: { favoritable: @favoritable, favorite: nil }
        )
      end
      format.html { redirect_back fallback_location: root_path, notice: "お気に入りを解除しました。" }
    end
  end

  private

  def set_favoritable
    @favoritable =
      if params[:event_id]
        Event.find(params[:event_id])
      elsif params[:shop_id]
        Shop.find(params[:shop_id])
      else
        raise ActiveRecord::RecordNotFound
      end
  end

  def create_favorite_notification!(favoritable)
    recipient =
      case favoritable
      when Event then favoritable.shop.user
      when Shop  then favoritable.user
      end

    return if recipient.nil? || recipient == current_user

    Notification.create!(
      recipient: recipient,
      actor: current_user,
      action: "favorited",
      notifiable: favoritable
    )
  end
end
