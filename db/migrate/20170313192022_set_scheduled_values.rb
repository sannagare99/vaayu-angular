class SetScheduledValues < ActiveRecord::Migration
  def self.up
    Trip.update_all("scheduled_approximate_duration=planned_approximate_duration")
    Trip.update_all("scheduled_approximate_distance=planned_approximate_distance")
    TripRoute.update_all("scheduled_distance=planned_distance")
    TripRoute.update_all("scheduled_duration=planned_duration")
    TripRoute.update_all("scheduled_route_order=planned_route_order")
    TripRoute.update_all("scheduled_start_location=planned_start_location")
    TripRoute.update_all("scheduled_end_location=planned_end_location")
  end

  def self.down
  end
end