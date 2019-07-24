class Reports::ReportTripWiseDriverExceptionDatatable
  include ReportsHelper
  def initialize(trip)
    @trip = trip
    @notifications = @trip.notifications
  end

  def as_json(options = {})
    {
        data: data
    }
  end

  def data
    {
      date: @trip.date.to_datetime&.strftime("%d-%m-%Y"),
      trip_id: @trip.id,
      shift_time: @trip.shift_time,
      direction: @trip.trip_type.humanize,
      driver_name: @trip.driver_name,
      plate_number: @trip.plate_number,
      out_of_geofence_driver_arrived: @notifications.map(&:message).select { |n| n == "out_of_geofence_driver_arrived" }.size,
      out_of_geofence_pick_up: @notifications.map(&:message).select { |n| n == "out_of_geofence_check_in" }.size,
      out_of_geofence_drop_off: @notifications.map(&:message).select { |n| n == "out_of_geofence_drop_off" }.size,
      panic_alert: @notifications.map(&:message).select { |n| n == "panic" }.size,
      car_broke_down: @notifications.map(&:message).select { |n| n == "car_broke_down" }.size
    }
  end
end
