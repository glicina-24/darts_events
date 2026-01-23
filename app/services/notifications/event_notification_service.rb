module Notifications
  class EventNotificationService
    REASON_FAVORITE_SHOP = "favorite_shop"
    REASON_FAVORITE_PRO  = "favorite_pro"

    def initialize(event, actor:)
      @event = event
      @actor = actor
    end

    def notify_event_created!
      recipients = recipients_with_reason_for_event_created

      # User を一括取得（N+1回避）
      users_by_id = User.where(id: recipients.keys).index_by(&:id)

      recipients.each do |user_id, notification_context|
        recipient = users_by_id[user_id]
        next unless recipient

        event_created!(recipient, notification_context)
      end
    end

    def recipients_with_reason_for_event_created
      recipients = {}
      add_shop_favoriters(recipients)
      add_pro_favoriters(recipients)

      recipients.each_value do |meta|
        meta[:reasons].uniq!
        meta[:pro_names].uniq!
      end

      recipients.delete(actor.id)
      recipients
    end

    def event_created!(recipient, notification_context)
      action = "event_created"
      dedupe_key = build_dedupe_key(action, recipient)

      delivery = EmailDelivery.create!(
        recipient: recipient,
        actor: @actor,
        action: action,
        notifiable: @event,
        dedupe_key: dedupe_key
      )

      EventMailer.event_created(@event, recipient, notification_context).deliver_later
      delivery.sent! if delivery.respond_to?(:sent!)
      :sent
    rescue ActiveRecord::RecordNotUnique
      :already_sent
    rescue => e # 送信失敗でもイベント作成は成功させたい
      delivery&.failed! if defined?(delivery) && delivery.respond_to?(:failed!)
      delivery&.update(error_message: "#{e.class}: #{e.message}") if defined?(delivery) && delivery
      Rails.logger.error("[mail] event_created failed: #{e.class} #{e.message}")
      :failed
    end

    private

    attr_reader :event, :actor # 外から書き換えさせたくない

    def build_dedupe_key(action, user) # 重複防止
      "email:#{action}:#{event.class.name}:#{event.id}:to:#{user.id}"
    end

    def add_shop_favoriters(recipients) # 店舗お気に入りユーザー
      Favorite.where(favoritable: event.shop).pluck(:user_id).each do |uid|
        recipients[uid] ||= base_context
        recipients[uid][:reasons] << REASON_FAVORITE_SHOP
      end
    end

    def add_pro_favoriters(recipients) # プロお気に入りユーザー
      pro_ids = event.pro_players.ids
      return if pro_ids.empty?
      pairs = Favorite.where(favoritable_type: "User", favoritable_id: pro_ids)
                      .pluck(:user_id, :favoritable_id)
      pro_name_by_id = User.where(id: pro_ids).pluck(:id, :name).to_h

      pairs.each do |uid, pro_id|
        recipients[uid] ||= base_context
        recipients[uid][:reasons] << REASON_FAVORITE_PRO
        recipients[uid][:pro_names] << pro_name_by_id[pro_id]
      end
    end

    def base_context
      { reasons: [], pro_names: [], shop_name: event.shop.name }
    end
  end
end
