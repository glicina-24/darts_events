class AddShopApplicationFieldsToShops < ActiveRecord::Migration[7.2]
  def change
    change_table :shops, bulk: true do |t|
      t.integer  :shop_status, null: false, default: 0 # pending
      t.datetime :shop_applied_at

      t.string :google_maps_url
      t.string :contact_email

      t.string   :email_verification_token_digest
      t.datetime :email_verification_sent_at
      t.datetime :email_verified_at
    end

    add_index :shops, :shop_status
    add_index :shops, :contact_email
    add_index :shops, :email_verification_token_digest, unique: true
  end
end
