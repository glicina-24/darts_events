class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.references :shop, null: false, foreign_key: true

      t.string  :title,          null: false
      t.text    :description

      t.datetime :start_datetime,  null: false
      t.datetime :end_datetime
      t.datetime :entry_deadline

      t.string  :location
      t.string  :address
      t.string  :prefecture
      t.string  :city

      t.decimal :latitude,  precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6

      t.integer :fee
      t.integer :capacity

      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :events, :start_datetime
  end
end
