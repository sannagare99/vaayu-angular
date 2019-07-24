class AddLocationsToTripRoute < ActiveRecord::Migration[5.0]
  def change
    add_column :trip_routes, :driver_arrived_location, :text
    add_column :trip_routes, :check_in_location, :text
    add_column :trip_routes, :drop_off_location, :text
    add_column :trip_routes, :missed_location, :text
  end
end