class AddStopNameToTripRoutes < ActiveRecord::Migration[5.0]
  def change
    add_column :trip_routes, :bus_stop_name, :text
  end
end