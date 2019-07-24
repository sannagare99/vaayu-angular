class AddStopAddressToTripRoutes < ActiveRecord::Migration[5.0]
  def change
    add_column :trip_routes, :bus_stop_address, :text
  end
end