class AllowNullActorIdOnNotifications < ActiveRecord::Migration[7.2]
  def change
    change_column_null :notifications, :actor_id, true
  end
end
