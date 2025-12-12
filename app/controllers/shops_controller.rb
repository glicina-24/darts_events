class ShopsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :set_shop, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_shop_owner!, only: [ :edit, :update, :destroy ]

  def index
    @shops = Shop.includes(:user).order(created_at: :desc)
  end

  def show
  end

  def new
    @shop = current_user.shops.build
  end

  def create
    @shop = current_user.shops.build(shop_params)

    if @shop.save
      redirect_to @shop, notice: "店舗を登録しました。"
    else
      flash.now[:alert] = "店舗登録に失敗しました。入力内容を確認してください。"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @shop.update(shop_params)
      redirect_to @shop, notice: "店舗情報を更新しました。"
    else
      flash.now[:alert] = "店舗情報の更新に失敗しました。入力内容を確認してください。"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @shop.destroy
    redirect_to shops_path, notice: "店舗を削除しました。", status: :see_other
  end

  private

  def set_shop
    @shop = Shop.find(params[:id])
  end

  def authorize_shop_owner!
    return if @shop.user == current_user

    redirect_to @shop, alert: "この店舗を編集・削除する権限がありません。"
  end

  def shop_params
    params.require(:shop).permit(
      :name,
      :description,
      :address,
      :prefecture,
      :city,
      :postal_code,
      :phone_number,
      :latitude,
      :longitude,
      images: []
    )
  end
end
