class AddScheduledTripValues < ActiveRecord::Migration[5.0]
  def change
  	#Values captured during planning stage
    rename_column :trips, :date, :planned_date
    rename_column :trips, :approximate_duration, :planned_approximate_duration
    rename_column :trips, :approximate_distance, :planned_approximate_distance

    #These values are captured keeping in mind the driver start location
    add_column :trips, :scheduled_approximate_duration, :integer
    add_column :trips, :scheduled_approximate_distance, :integer

    #Planned trip route values are stored during planning
    rename_column :trip_routes, :distance, :planned_distance
    rename_column :trip_routes, :duration, :planned_duration
    rename_column :trip_routes, :route_order, :planned_route_order
    rename_column :trip_routes, :start_location, :planned_start_location
    rename_column :trip_routes, :end_location, :planned_end_location

    # Add new columns to capture trip route values when driver starts a trip
    add_column :trip_routes, :scheduled_distance, :integer
    add_column :trip_routes, :scheduled_duration, :integer
    add_column :trip_routes, :scheduled_route_order, :integer
    add_column :trip_routes, :scheduled_start_location, :text
    add_column :trip_routes, :scheduled_end_location, :text
  end
end