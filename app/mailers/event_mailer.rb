class EventMailer < ApplicationMailer
  def event_created(event, recipient, notification_context)
    @event = event
    @recipient = recipient
    @context = notification_context # "favorite_shop" / "favorite_pro" / nil（任意）

    mail(
      to: recipient.email,
      subject: subject_for_event_created
    )
  end

  private

  def subject_for_event_created
    shop = @context[:shop_name]
    parts = []

    parts << "【新着イベント】"
    parts << shop if shop.present?
    parts << @event.title

    if @context[:reasons].include?(Notifications::EventNotificationService::REASON_FAVORITE_PRO)
      parts << "（お気に入りプロ参加）"
    elsif @context[:reasons].include?(Notifications::EventNotificationService::REASON_FAVORITE_SHOP)
      parts << "（お気に入り店舗）"
    end

    parts.compact.join(" ")
  end
end
