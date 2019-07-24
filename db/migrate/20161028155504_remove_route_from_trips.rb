class RemoveRouteFromTrips < ActiveRecord::Migration[5.0]
  def change
    remove_column :trips, :route, :text
  end
end
