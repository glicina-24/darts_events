class CreateEmailDeliveries < ActiveRecord::Migration[7.2]
  def change
    create_table :email_deliveries do |t|
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.references :actor, foreign_key: { to_table: :users }
      t.string :action, null: false
      t.string :notifiable_type, null: false
      t.bigint :notifiable_id, null: false
      t.string :dedupe_key, null: false
      t.string :status, null: false, default: "sent"
      t.text :error_message

      t.timestamps
    end
    add_index :email_deliveries, :dedupe_key, unique: true
    add_index :email_deliveries, [ :notifiable_type, :notifiable_id ]
    add_index :email_deliveries, [ :recipient_id, :created_at ]
  end
end
