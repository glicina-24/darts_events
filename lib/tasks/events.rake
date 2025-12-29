namespace :events do
  task update_status: :environment do
    Event.finish_past_events!
  end
end
