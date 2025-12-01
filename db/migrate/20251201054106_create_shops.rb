class CreateShops < ActiveRecord::Migration[7.2]
  def change
    create_table :shops do |t|
      t.string :name, null: false
      t.text :description
      t.string :address
      t.string :prefecture
      t.string :city
      t.string :postal_code
      t.string :phone_number
      t.decimal :latitude,  precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :shops, :name
    add_index :shops, :prefecture
    add_index :shops, :city
  end
end
