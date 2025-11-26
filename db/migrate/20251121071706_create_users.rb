class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string  :name,            null: false
      t.string  :email,           null: false
      t.string  :password_digest, null: false
      t.boolean :shop_owner,      null: false, default: false
      t.boolean :pro_player,      null: false, default: false

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
