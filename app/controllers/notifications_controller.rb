class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications =
      current_user.received_notifications
                  .includes(:actor, :notifiable)
                  .order(created_at: :desc)
                  .page(params[:page])
                  .per(20)
  end

  def read
    notification = current_user.received_notifications.find(params[:id])
    notification.update!(read_at: Time.current) if notification.read_at.nil?

    redirect_to redirect_path_for(notification)
  end

  private

  def redirect_path_for(notification)
    case notification.notifiable
    when Event
      event_path(notification.notifiable)
    when Shop
      shop_path(notification.notifiable)
    else
      notifications_path
    end
  end
end
