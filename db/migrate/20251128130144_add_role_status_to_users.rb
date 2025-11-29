class AddRoleStatusToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :shop_owner_status, :integer, null: false, default: 0
    add_column :users, :pro_player_status,  :integer, null: false, default: 0
  end
end
