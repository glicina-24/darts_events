class FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_favoritable

  def create
    favorite = current_user.favorites.find_or_initialize_by(favoritable: @favoritable)

    if favorite.new_record? && !favorite.save
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = favorite.errors.full_messages.first
          render turbo_stream: turbo_stream.replace(
            helpers.dom_id(@favoritable, :favorite_button),
            partial: "favorites/button",
            locals: { favoritable: @favoritable, favorite: nil }
          ), status: :unprocessable_entity
        end
        format.html do
          redirect_back fallback_location: root_path, alert: favorite.errors.full_messages.first
        end
      end
      return
    end

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
      elsif params[:user_id]
        User.find(params[:user_id])
      else
        raise ActiveRecord::RecordNotFound
      end
  end
end
