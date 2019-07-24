class CreateBusTripRoutes < ActiveRecord::Migration[5.0]
  def change
    create_table :bus_trip_routes do |t|
      t.text :stop_name
      t.text :stop_address
      t.decimal :stop_latitude, precision: 10, scale: 6
      t.decimal :stop_longitude, precision: 10, scale: 6
      t.integer :stop_order
      t.belongs_to :bus_trip, foreign_key: true
    end
  end
end