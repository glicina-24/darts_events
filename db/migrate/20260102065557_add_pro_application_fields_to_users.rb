class AddProApplicationFieldsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :pro_sns_url, :string
    add_column :users, :pro_applied_at, :datetime
  end
end
