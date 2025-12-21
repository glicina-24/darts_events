class AddUniqueIndexToEventParticipants < ActiveRecord::Migration[7.2]
  def change
    add_index :event_participants, [ :event_id, :user_id ], unique: true
  end
end
