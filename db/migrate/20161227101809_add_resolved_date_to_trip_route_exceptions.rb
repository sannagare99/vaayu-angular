class AddResolvedDateToTripRouteExceptions < ActiveRecord::Migration[5.0]
  def change
    add_column :trip_route_exceptions, :resolved_date, :datetime
  end
end
