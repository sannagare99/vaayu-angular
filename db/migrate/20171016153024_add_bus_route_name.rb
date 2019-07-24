class AddBusRouteName < ActiveRecord::Migration[5.0]
  def change
    add_column :bus_trip_routes, :name, :text
  end
end