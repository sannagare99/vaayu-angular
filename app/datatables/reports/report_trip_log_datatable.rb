class Reports::ReportTripLogDatatable
  include ReportsHelper
  def initialize(trip)
    @trip = trip
    @trip_routes = trip&.trip_routes
    @driver_arrived_date = @trip_routes&.first&.driver_arrived_date
    @last_checkin_date = @trip_routes&.last&.driver_arrived_date    
    @employee_trip_date = @trip_routes.first&.employee_trip&.date
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
      driver: @trip.driver_full_name,
      operator: @trip&.driver&.logistics_company&.name,
      plate_number: @trip.plate_number,
      shift_time: @trip.shift_time,
      direction: @trip.trip_type.humanize,
      actual_time: @trip.check_in? ? @trip.completed_date&.in_time_zone("Kolkata")&.strftime("%H:%M")&.to_s: @last_checkin_date&.in_time_zone("Kolkata")&.strftime("%H:%M")&.to_s,
      trip_created: @trip.created_at&.in_time_zone("Kolkata")&.strftime("%d-%m-%Y %H:%M"),
      trip_assigned: trip_assigned,
      trip_accepted: @trip.trip_accept_time&.in_time_zone("Kolkata")&.strftime("%d-%m-%Y %H:%M")&.to_s,
      trip_started: @trip.start_date&.in_time_zone("Kolkata")&.strftime("%d-%m-%Y %H:%M")&.to_s,
      number_of_riders: @trip_routes.size,
      distance: sprintf("%.1f", (@trip.scheduled_approximate_distance / 1000.0)),
      duration: @trip.real_duration,
      status: @trip.cancel_status.blank? ? @trip.status.humanize : 'CWE',
      exception_detail: @trip.cancel_status,
      vehicle_capacity: @trip.seats,
      delta_time: get_delta_time
    } 
  end

  private

  def trip_assigned
    if @trip.trip_assign_date.present?
      @trip.trip_assign_date&.in_time_zone("Kolkata")&.strftime("%d-%m-%Y %H:%M")
    else
      @trip.notifications.operator_assigned_trip.first&.created_at&.in_time_zone("Kolkata")&.strftime("%d-%m-%Y %H:%M")
    end
  end

  def get_delta_time
    zone = ActiveSupport::TimeZone.new("Chennai")
    employee_trip_date = DateTime.strptime("#{@trip.date} #{@trip.shift_time}", "%Y-%m-%d %H:%M").in_time_zone(zone)
    return delta_time = ((@trip.completed_date&.in_time_zone(zone) - @employee_trip_date.in_time_zone(zone)) / 60).to_i if @trip.check_in? && @trip.completed_date
    return delta_time = ((@driver_arrived_date&.in_time_zone(zone) - @employee_trip_date.in_time_zone(zone)) / 60).to_i if @trip.check_out? && @driver_arrived_date
  end
end



