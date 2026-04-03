class EventsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_event, only: %i[show edit update destroy]
  before_action :require_shop_owner, only: %i[new confirm create]
  before_action :set_shop_for_event, only: %i[new confirm create]
  before_action :authorize_event_owner!, only: %i[edit update destroy]
  before_action :set_owned_shops, only: %i[new confirm create edit update]

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

  def confirm
    unless request.post?
      # 投稿完了後にブラウザバックで confirm へ戻った場合の退避先。
      # TODO: マイページの投稿一覧実装後は、root_path から投稿一覧への導線に置き換える。
      redirect_to root_path, alert: "投稿済みのイベントです。"
      return
    end

    @shop = current_user.shops.visible.find_by(id: event_params[:shop_id])

    unless @shop
      flash.now[:alert] = "不正な店舗が指定されました。"
      @event = build_event_without_shop
      render :new, status: :unprocessable_content
      return
    end

    @event, @image_blobs = build_event_for_confirm_or_create(
      shop: @shop, signed_ids: direct_upload_image_signed_ids
    )

    allowed_types = %w[image/jpeg image/png image/webp]

    if @image_blobs.any? { |blob| !allowed_types.include?(blob.content_type) }
      @event.errors.add(:images, "はJPEG / PNG / WEBPのみアップロードできます")
      render :new, status: :unprocessable_content
      return
    end

    if @event.valid?
      render :confirm
    else
      render :new, status: :unprocessable_content
    end
  end

  def create
    @shop = current_user.shops.visible.find_by(id: event_params[:shop_id])

    unless @shop
      flash.now[:alert] = "不正な店舗が指定されました。"
      @event = build_event_without_shop

      render :new, status: :unprocessable_entity
      return
    end

    # confirm画面経由の hidden(image_signed_ids) を優先。
    # 直接POSTされた場合は direct_upload側(images) も拾えるようにする。
    signed_ids = image_signed_ids.presence || direct_upload_image_signed_ids
    uploaded_files = uploaded_images

    @event, blobs = build_event_for_confirm_or_create(shop: @shop, signed_ids: signed_ids)

    ActiveRecord::Base.transaction do
      @event.images.attach(blobs) if blobs.any?
      @event.images.attach(uploaded_files) if uploaded_files.any?
      @event.save!
      create_new_event_notifications!(@event)
    end

    Notifications::EventNotificationService.new(@event, actor: current_user).notify_event_created!

    redirect_to @event, notice: "イベントを投稿しました。"
  rescue ActiveRecord::RecordInvalid
    flash.now[:alert] = "イベントの投稿に失敗しました。入力内容を確認してください。"
    render :new, status: :unprocessable_content
  end

  def edit
  end

  def update
    ActiveRecord::Base.transaction do
      @event.images.attach(event_params[:images]) if event_params[:images].present?
      @event.update!(event_params.except(:pro_player_ids, :images))
      @event.pro_players = User.where(id: pro_player_ids)
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
      images: [],
      image_signed_ids: []
    )
  end

  def set_event; @event = Event.includes(:shop, :pro_players, images_attachments: :blob).find(params[:id]); end

  def require_shop_owner
    unless current_user.shops.visible.exists?
      redirect_to new_shop_path, alert: "イベント投稿には店舗登録が必要です。先に店舗を登録してください。"
    end
  end

  def set_shop_for_event
    return if action_name.in?(%w[edit update])

    if current_user.shops.visible.empty?
      redirect_to new_shop_path, alert: "まず店舗を登録してください。"
    end
  end

  def set_owned_shops
    @owned_shops = current_user.shops.visible.order(:name)
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

  def direct_upload_image_signed_ids
    Array(event_params[:images]).filter_map do |value|
      value if value.is_a?(String) && value.present?
    end
  end

  def uploaded_images
    Array(event_params[:images]).select do |value|
      value.respond_to?(:tempfile) &&
        value.respond_to?(:original_filename) &&
        value.respond_to?(:content_type)
    end
  end

  def pro_player_ids
    Array(event_params[:pro_player_ids]).reject(&:blank?)
  end

  def image_signed_ids
    Array(event_params[:image_signed_ids]).reject(&:blank?)
  end

  def base_event_attributes
    event_params.except(:pro_player_ids, :images, :image_signed_ids)
  end

  def build_event_without_shop
    event = Event.new(base_event_attributes)
    event.pro_players = User.where(id: pro_player_ids)
    event
  end

  def build_event_for_confirm_or_create(shop:, signed_ids:)
    event = shop.events.build(base_event_attributes)
    event.pro_players = User.where(id: pro_player_ids)

    blobs = Array(signed_ids).reject(&:blank?).filter_map do |sid|
      ActiveStorage::Blob.find_signed(sid)
    end

    [ event, blobs ]
  end
end
