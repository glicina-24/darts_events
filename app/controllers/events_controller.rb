class EventsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create ]
  before_action :require_shop_owner, only: [ :new, :create ]
  before_action :set_shop_for_event, only: [ :new, :create ]

  def index
    @events = Event.includes(shop: :user).order(start_datetime: :asc)
  end

  def show
    @event = Event.includes(:shop).find(params[:id])
  end

  def new
    @event = @shop.events.build
  end

  def create
    @event = @shop.events.build(event_params)
    @event.status ||= :scheduled

    if @event.save
      redirect_to @event, notice: "イベントを投稿しました。"
    else
      flash.now[:alert] = "イベントの投稿に失敗しました。入力内容を確認してください。"
      render :new, status: :unprocessable_entity
    end
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
      :image
    )
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
end
