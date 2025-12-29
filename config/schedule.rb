set :environment, :production
set :output, "log/cron.log"

every 1.hour do
  rake "events:update_status"
end
