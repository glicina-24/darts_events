namespace :events do
  task update_status: :environment do
    started_at = Time.current
    Rails.logger.info("[CRON] start events:update_status at=#{started_at}")

    Event.finish_past_events!

    Rails.logger.info("[CRON] finish events:update_status at=#{Time.current}")
  rescue => e
    Rails.logger.error("[CRON] error events:update_status #{e.class}: #{e.message}")
    raise
  end
end
