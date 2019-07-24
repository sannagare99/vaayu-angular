require 'services/google_service'
require 'services/trip_validation_service'

class TripValidationController < ApplicationController
  # ToDo: Move this to yaml file
  DEFAULT_DRIVER_CHECKIN_START_TIME = 90.minutes
  DEFAULT_DRIVER_CHECKOUT_START_TIME = 10.minutes
  PICKUP_OR_DROP_SWAP_RADIUS = 5 # in km
  ONBOARD_PASSENGER_TIME = 0
  TIME_TO_ARRIVE = 10
  DRIVER_ASSIGN_REQUEST_EXPIRATION = 3.minutes

  MAXIMUM_TRIP_DURATION = 120
  MAXIMUM_TRIP_DISTANCE = 60 # in km

  def check_if_valid_trip(employee_trips, trip_type)
    employee_trips = EmployeeTrip.where("employee_trips.id in (?)", employee_trips)
    waypoints = employee_trips.joins(:employee).order("employees.distance_to_site DESC")
    return "empty" if waypoints.empty?
    #Check for female filter
    female_filter_failed = false

    if is_guard_required(waypoints)
      female_filter_failed = true
    end

    # if trip_type == "check_in" && waypoints.first.employee&.gender == "female" && !is_day_shift(waypoints.first.date) && ENV["ENALBE_GUARD_PROVISIONGING"] == "true"
    #   #Apply female filter
    #   female_filter_failed = true
    # elsif trip_type == "check_out" && waypoints.last.employee&.gender == "female" && !is_day_shift(waypoints.first.date) && ENV["ENALBE_GUARD_PROVISIONGING"] == "true"
    #   #Apply female filter
    #   female_filter_failed = true
    # end

    waypoints = waypoints.to_a.compact
    first_waypoint = waypoints.shift
    last_waypoint = waypoints.pop if trip_type == "check_out"

    origin = first_waypoint.site_location

    destination = first_waypoint.home_address
    trip_start_date = employee_trips.maximum(:date).in_time_zone("Kolkata")
    if trip_type == "check_in"
      trip_start_date = trip_start_date - DEFAULT_DRIVER_CHECKIN_START_TIME
    else
      trip_start_date = trip_start_date + DEFAULT_DRIVER_CHECKOUT_START_TIME
    end
    trip_start_date = Time.now.in_time_zone("Kolkata") if trip_start_date < Time.now.in_time_zone("Kolkata")

    begin
      route = get_route(origin, destination, trip_start_date, waypoints.map{|et| et.home_address})

      reordered_waypoints = route.first[:waypoint_order].map{|i| waypoints[i]}
      reordered_waypoints.push(first_waypoint)

      route_data = route.first[:legs]

      if trip_type == "check_in"
        reordered_waypoints = reordered_waypoints.reverse
        route_data = route_data.reverse
      end

      total_distance = 0
      total_duration = 0
      reordered_waypoints.each_with_index.map do |employee_trip, i|
        if trip_type == "check_in"
          start_location, end_location = [route_data[i][:end_location],route_data[i][:start_location]]
        else
          start_location, end_location = [route_data[i][:start_location],route_data[i][:end_location]]
        end

        new_route_data_intr = get_route(start_location, end_location, trip_start_date).first[:legs]
        total_distance += route_data[i][:distance][:value]
        total_duration += (new_route_data_intr[0][:duration_in_traffic][:value].to_f / 60).ceil
      end
    rescue
      return "failed"
    end

    maximum_trip_distance = Configurator.get('max_allowed_distance_trip').to_i
    if (total_distance / 1000) > maximum_trip_distance
      return "max_distance_failed"
    end

    maximum_trip_duration = Configurator.get('max_duration_allowed_trip').to_i
    if total_duration > maximum_trip_duration
      return "max_duration_failed"
    end

    if female_filter_failed
      return "female_filter_failed"
    end

    return "passed" 
  end

  def is_guard_required(waypoints)
    @employee_trip_ids = []

    waypoints.each do |et|
      @employee_trip_ids.push(et.id)
    end

    TripValidationService.is_female_exception(@employee_trip_ids, waypoints.first.trip_type)
  end

  def get_route(start_location, end_location, trip_start_date="", waypoints=[])
    trip_start_date = Time.now.in_time_zone(Time.zone).to_i if trip_start_date.blank?
    GoogleService.new.directions(
      start_location,
      end_location,
      mode: 'driving',
      waypoints: waypoints,
      optimize_waypoints: !waypoints.empty?,
      departure_time: trip_start_date
    )
  end  
end
