module Notifications
  class EventNotificationService
    def initialize(event, actor)
      @event = event
      @actor = actor
    end

    def event_created_smoke_test!
      EventMailer.event_created(@event, @actor).deliver_later
    rescue => e
      Rails.logger.error("[mail] event_created failed: #{e.class} #{e.message}")
    end

    private

    attr_reader :event, :actor
  end
end
