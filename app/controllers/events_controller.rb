class EventsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_event, only: %i[show edit update destroy]
  before_action :require_shop_owner, only: %i[new create]
  before_action :set_shop_for_event, only: %i[new create]
  before_action :authorize_event_owner!, only: %i[edit update destroy]
  before_action :set_owned_shops, only: %i[new create edit update]

  def index
    @q = Event.ransack(params[:q])
    @events = @q.result
      .includes(:shop, pro_players: [], images_attachments: :blob)
      .order(start_datetime: :asc)
      .page(params[:page]).per(12)

    @pros = User.approved_pros.order(:name)
    @pagination_params = { q: q_params.to_h }

    if user_signed_in?
      @favorites_by_event_id = current_user.favorites
        .where(favoritable_type: "Event", favoritable_id: @events.map(&:id))
        .index_by(&:favoritable_id)
    else
      @favorites_by_event_id = {}
    end
  end

  def show
  end

  def new
    @event = Event.new
  end

  def create
    @shop = current_user.shops.find_by(id: event_params[:shop_id])

    unless @shop
      flash.now[:alert] = "不正な店舗が指定されました。"
      @event = Event.new(event_params)
      render :new, status: :unprocessable_entity
      return
    end

    @event = @shop.events.build(event_params.except(:pro_player_ids, :images))

    ActiveRecord::Base.transaction do
      @event.save!
      @event.pro_players = User.where(id: pro_player_ids)
      @event.images.attach(event_params[:images]) if event_params[:images].present?
      create_new_event_notifications!(@event)
    end

    Notifications::EventNotificationService.new(@event, actor: current_user).event_created_smoke_test!

    redirect_to @event, notice: "イベントを投稿しました。"
  rescue ActiveRecord::RecordInvalid
    flash.now[:alert] = "イベントの投稿に失敗しました。入力内容を確認してください。"
    render :new, status: :unprocessable_entity
  end

  def edit
  end

  def update
    ActiveRecord::Base.transaction do
      @event.update!(event_params.except(:pro_player_ids, :images))
      @event.pro_players = User.where(id: pro_player_ids)

      @event.images.attach(event_params[:images]) if event_params[:images].present?
    end

    redirect_to @event, notice: "イベントを更新しました。"
  rescue ActiveRecord::RecordInvalid
    flash.now[:alert] = "更新に失敗しました。"
    render :edit, status: :unprocessable_entity
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
      :shop_id,
      :title,
      :description,
      :start_datetime,
      :end_datetime,
      :address,
      :prefecture,
      :city,
      :latitude,
      :longitude,
      :fee,
      :capacity,
      :entry_deadline,
      pro_player_ids: [],
      images: []
    )
  end

  def set_event; @event = Event.includes(:shop, :pro_players, images_attachments: :blob).find(params[:id]); end

  def require_shop_owner
    unless current_user&.shop_owner?
      redirect_to new_shop_path, alert: "イベント投稿には店舗登録が必要です。先に店舗を登録してください。"
    end
  end

  def set_shop_for_event
    return if action_name.in?(%w[edit update])

    if current_user.shops.empty?
      redirect_to new_shop_path, alert: "まず店舗を登録してください。"
    end
  end

  def set_owned_shops
    @owned_shops = current_user.shops.order(:name)
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
      :pro_players_id_eq
    )
  end

  def create_new_event_notifications!(event)
    shop = event.shop

    # 店舗をお気に入りしてるユーザー（店主自身は除外）
    user_ids = Favorite.where(favoritable: shop).where.not(user_id: shop.user_id).pluck(:user_id)

    now = Time.current
    rows = user_ids.map do |uid|
      {
        recipient_id: uid,
        actor_id: shop.user_id,
        action: "new_event",
        notifiable_type: "Event",
        notifiable_id: event.id,
        created_at: now,
        updated_at: now
      }
    end

    Notification.insert_all!(rows) if rows.any?
  end

  def pro_player_ids
    Array(event_params[:pro_player_ids]).reject(&:blank?)
  end
end
