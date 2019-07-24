class DriverTimelinePresenter
  attr_reader :driver

  def initialize(drivers)
    @drivers=drivers.map { |de| extract_driver(de[0], de[1]) }
  end

  def extract_driver(driver, trips)
    local_driver={}
    local_driver[:name] = driver_name(driver)
    local_driver[:plate_number] = plate_number(driver)
    local_driver[:seats] = driver_seats(driver)
    local_driver[:trips] = extract_trips(trips)
    local_driver
  end

  def as_json
    {data: @drivers}
  end

  def plate_number(driver)
    driver&.vehicle&.plate_number || ""
  rescue
    ""
  end

  def driver_name(driver)
    return 'unassigned' if driver.nil?
    driver.f_name + ' ' + driver.l_name
  end

  def driver_seats(driver)
    driver&.vehicle&.seats if driver&.vehicle&.seats > 0
  rescue
    ""
  end
  def extract_trips(trips)
    trips.map do |trip|
      local_trip = {}
      local_trip[:id] = trip.id
      local_trip[:status] = trip.status
      local_trip[:date] = trip.start_date || trip.scheduled_date
      local_trip[:name] = trip_name(trip)
      local_trip[:end_date] = trip_end_time(trip)
      local_trip[:notifications] = [trip.recent_unresolved_notification&.attributes]
      local_trip
    end
  end

  def trip_name(trip)
    employee_trips = EmployeeTrip.where(:trip_id => trip.id)
    if trip.check_in?
      "#{employee_trips&.first&.date&.strftime('%d/%m')} IN #{employee_trips&.first&.date&.strftime('%H:%M')} - #{trip.id.to_s}"
    else
      "#{employee_trips&.first&.date&.strftime('%d/%m')} OUT #{employee_trips&.first&.date&.strftime('%H:%M')} - #{trip.id.to_s}"
    end
  end
  def trip_end_time(trip)
    return trip.completed_date if trip.status == 'completed'
    trip.scheduled_date + trip.scheduled_approximate_duration.minutes
  end
end
