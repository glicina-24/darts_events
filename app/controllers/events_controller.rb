class EventsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_event, only: [ :show, :edit, :update, :destroy ]
  before_action :require_shop_owner, only: [ :new, :create ]
  before_action :set_shop_for_event, only: [ :new, :create ]
  before_action :authorize_event_owner!, only: [ :edit, :update, :destroy ]

  def index
    @q = Event.ransack(params[:q])
    @events = @q.result.includes(:shop, participants: []).order(start_datetime: :asc).page(params[:page]).per(12)
    @pros = User.approved_pros.order(:name)

    @pagination_params = { q: q_params.to_h }
  end

  def show
  end

  def new
    @event = @shop.events.build
  end

  def create
    @event = @shop.events.build(event_params)

    if @event.save
      redirect_to @event, notice: "イベントを投稿しました。"
    else
      flash.now[:alert] = "イベントの投稿に失敗しました。入力内容を確認してください。"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event.update(event_params.except(:images))
      @event.images.attach(event_params[:images]) if event_params[:images].present?
      redirect_to @event, notice: "イベントを更新しました。"
    else
      flash.now[:alert] = "更新に失敗しました。"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to events_path, notice: "イベントを削除しました。", status: :see_other
  end

  def destroy_image
    @event = current_user.events.find(params[:id])
    image = @event.images.find(params[:image_id])

    image.purge

    redirect_to edit_event_path(@event), notice: "画像を削除しました。"
  end

  private

  def event_params
    params.require(:event).permit(
      :title,
      :description,
      :start_datetime,
      :end_datetime,
      :location,
      :address,
      :prefecture,
      :city,
      :latitude,
      :longitude,
      :fee,
      :capacity,
      :entry_deadline,
      images: []
    )
  end

  def set_event
    @event = Event.includes(:shop).find(params[:id])
  end

  def require_shop_owner
    unless current_user&.shop_owner?
      redirect_to new_shop_path, alert: "イベント投稿には店舗登録が必要です。先に店舗を登録してください。"
    end
  end

  def set_shop_for_event
    @shop = current_user.shops.first
    if @shop.nil?
      redirect_to new_shop_path, alert: "まず店舗を登録してください。"
    end
  end

  def authorize_event_owner!
    redirect_to @event, alert: "このイベントを編集する権限がありません。" unless @event.owned_by?(current_user)
  end

  def q_params
    return {} unless params[:q].is_a?(ActionController::Parameters)
    params.require(:q).permit(
      :title_cont,
      :shop_name_cont,
      :shop_prefecture_eq,
      :start_datetime_gteq,
      :start_datetime_lteq,
      :participants_id_eq
    )
  end
end
