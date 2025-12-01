class EventsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]
  before_action :require_approved_store_owner, only: [:new, :create]

  def index
    @events = Event.status_published.includes(:user).order(start_at: :asc)
  end

  def show
    @event = Event.find(params[:id])
  end

  def new
    @event = current_user.events.build
  end

  def create
    @event = current_user.events.build(event_params)
    @event.status = :published

    if @event.save
      redirect_to @event, notice: "イベントを投稿しました。"
    else
      flash.now[:alert] = "イベントの投稿に失敗しました。入力内容を確認してください。"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def event_params
    params.require(:event).permit(:title, :description, :start_at, :place, :capacity)
  end

  def require_approved_store_owner
    unless current_user&.approved_store_owner?
      redirect_to stores_path, alert: "イベント投稿には承認済みの店舗登録が必要です。まず店舗を登録してください。"
    end
  end
end