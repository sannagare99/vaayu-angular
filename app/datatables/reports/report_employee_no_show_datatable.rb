class Reports::ReportEmployeeNoShowDatatable
  include ReportsHelper
  def initialize(trip)
    @trip = trip
  end

  def as_json(options = {})
    {
        data: data
    }
  end

  def data
    {
      date: @trip.date.to_datetime&.strftime("%d-%m-%Y"),
      trip_id: @trip.trip_id,
      status: @trip.trip_status.titleize,
      direction: @trip.direction.to_i == 0 ? "Check In" : "Check Out",
      shift_time: get_date_time(@trip.date, @trip.shift_time, "time"),
      driver_name: @trip.driver_name,
      vehicle: @trip.vehicle_no,
      employee_id: @trip.employee_id,
      employee_name: @trip.employee_name,
      gender: Employee.genders.keys[@trip.gender],
      employee_pick_up_location: lat_lng_to_string(@trip.planned_start_location),
      no_show_triggered_location: lat_lng_to_string(@trip.driver_arrived_location),
      no_show_trigger_time: @trip.missed_date&.strftime("%d-%m-%Y %H:%M")
    }
  end

  def lat_lng_to_string(dat)
    dat.present? ? "lat: #{dat[:lat]}, lng: #{dat[:lng]}" : ""
  end
end



