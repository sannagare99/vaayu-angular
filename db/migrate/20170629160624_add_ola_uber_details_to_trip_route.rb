class AddOlaUberDetailsToTripRoute < ActiveRecord::Migration[5.0]
  def change
    add_column :trip_routes, :cab_type, :text
    add_column :trip_routes, :cab_fare, :integer
    add_column :trip_routes, :cab_driver_name, :text
    add_column :trip_routes, :cab_licence_number, :text
    add_column :trip_routes, :cab_start_location, :text
    add_column :trip_routes, :cab_end_location, :text
  end
end