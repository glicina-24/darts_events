class FixDefaultAndNullOnUsersRole < ActiveRecord::Migration[7.2]
  def change
    change_column_default :users, :role, from: nil, to: 0
    change_column_null :users, :role, false, 0
  end
end
