class AddGeofenceTimeLocationToTripRoutes < ActiveRecord::Migration[5.0]
  def change
    add_column :trip_routes, :geofence_driver_arrived_date, :datetime
    add_column :trip_routes, :geofence_completed_date, :datetime
    add_column :trip_routes, :geofence_driver_arrived_location, :text
    add_column :trip_routes, :geofence_completed_location, :text
    add_column :trips, :trip_accept_location, :text
  end
end