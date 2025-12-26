class SetDefaultStatusOnEvents < ActiveRecord::Migration[7.2]
  def change
    def up
      execute "UPDATE events SET status = 0 WHERE status IS NULL"
      change_column_default :events, :status, from: nil, to: 0
      change_column_null :events, :status, false
    end

    def down
      change_column_null :events, :status, true
      change_column_default :events, :status, from: 0, to: nil
    end
  end
end
