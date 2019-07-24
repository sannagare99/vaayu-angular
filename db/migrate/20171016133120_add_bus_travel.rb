class AddBusTravel < ActiveRecord::Migration[5.0]
  def change
    add_column :employees, :bus_travel, :boolean, :default => false
    add_reference :employees, :bus_trip_route, index: true
  end
end