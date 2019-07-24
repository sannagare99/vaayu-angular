class CreateZones < ActiveRecord::Migration[5.0]
  def change
    create_table :zones do |t|
      t.integer :name

      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6

      t.timestamps
    end
  end
end
