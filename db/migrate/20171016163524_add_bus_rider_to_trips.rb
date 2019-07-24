class AddBusRiderToTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :bus_rider, :boolean, :default => false
    add_column :employee_trips, :bus_rider, :boolean, :default => false
    add_column :trip_routes, :bus_rider, :boolean, :default => false
  end
end