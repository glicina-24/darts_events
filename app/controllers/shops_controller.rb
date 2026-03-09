class ShopsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :set_shop, only: [ :edit, :update, :destroy ]
  before_action :authorize_shop_owner!, only: [ :edit, :update, :destroy ]

  def index
    @shops = Shop.visible.includes(:user).order(created_at: :desc).page(params[:page]).per(12)
    if user_signed_in?
      @favorite_shop_ids = current_user
        .favorites
        .where(favoritable_type: "Shop")
        .pluck(:favoritable_id)
    else
      @favorite_shop_ids = []
    end
  end

  def show
    @shop = Shop.visible.find(params[:id])
  end

  def new
    @shop = current_user.shops.build
  end

  def create
    @shop = current_user.shops.build(shop_params)
    @shop.shop_status = :pending
    @shop.shop_applied_at = Time.current

    if @shop.save
      raw_token = @shop.generate_email_verification_token!
      Notifications::ShopEmailVerificationService.call(shop: @shop, raw_token: raw_token)

      redirect_to shops_path, notice: "店舗登録を申請しました。確認メールを送信しました。"
    else
      flash.now[:alert] = "店舗登録申請に失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end

  def verify_email
    @shop = Shop.find(params[:id])

    if @shop.email_verified?
      redirect_to shops_path, notice: "このメール確認はすでに完了しています。"
    elsif @shop.email_verification_token_valid?(params[:token])
      @shop.mark_email_verified!
      redirect_to shops_path, notice: "メール確認が完了しました。管理者承認をお待ちください。"
    else
      redirect_to shops_path, alert: "確認リンクが無効、または有効期限切れです。"
    end
  end

  def edit
  end

  def update
    if @shop.update(shop_params.except(:images))
      @shop.images.attach(shop_params[:images]) if shop_params[:images].present?
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

  def destroy_image
    @shop = current_user.shops.find(params[:id])
    image = @shop.images.find(params[:image_id])
    image.purge
    redirect_to edit_shop_path(@shop), notice: "画像を削除しました。"
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
      :google_maps_url,
      :contact_email,
      images: []
    )
  end
end
