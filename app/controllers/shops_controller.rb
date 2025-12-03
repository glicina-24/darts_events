class ShopsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create ]

  def index
    # ひとまず全部表示。あとで「公開フラグ」とか付けてもOK
    @shops = Shop.includes(:user).order(created_at: :desc)
  end

  def show
    @shop = Shop.find(params[:id])
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

  private

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
