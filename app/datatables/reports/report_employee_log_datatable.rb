class Reports::ReportEmployeeLogDatatable
  include ReportsHelper
  def initialize(trip_route)
    @trip_route = trip_route
    @trip = trip_route.trip
    @status_names = { on_board: "Picked Up", missed: "No Show", canceled: "Canceled", completed: "Picked Up" }    
  end

  def as_json(options = {})
    {
        data: data
    }
  end

  def data
    wait_time = @trip_route.driver_arrived_date.present? && @trip_route.on_board_date.present? ? Time.at(@trip_route.on_board_date-@trip_route.driver_arrived_date).utc.strftime("%M").to_i : ""
    {
      date:  @trip_route.date.to_datetime&.strftime("%d-%m-%Y"),
      trip_id: @trip_route.trip_id,
      driver_name: driver_name,
      operator: @trip&.driver&.logistics_company&.name,
      vehicle_number: @trip&.vehicle&.plate_number,
      status: @trip_route.trip_cancel_status.blank? ? @trip_route.trips_status.humanize : 'CWE',
      shift_time: @trip_route.shift_time,
      direction: @trip_route.trip_type.to_i == 0 ? "Check In" : "Check Out",
      employee_id: @trip_route.employee_id,
      rider_name: @trip_route.employee_name,
      notified_eta: @trip_route.trip_type.to_i == 0 ? @trip_route.eta&.in_time_zone("Kolkata")&.strftime("%H:%M").to_s : @trip_route.eta&.in_time_zone("Kolkata")&.strftime("%H:%M").to_s,
      i_am_here: @trip_route.driver_arrived_date&.in_time_zone("Kolkata")&.strftime("%d-%m-%Y %H:%M").to_s,
      pick_up_time: @trip_route.on_board_date&.in_time_zone("Kolkata")&.strftime("%d-%m-%Y %H:%M").to_s,
      drop_off_time: @trip_route.completed_date&.in_time_zone("Kolkata")&.strftime("%d-%m-%Y %H:%M").to_s,
      employee_status: @status_names.keys.include?(@trip_route.status.to_sym) ? @status_names[@trip_route.status.to_sym] : "",
      exception_detail: @trip_route.cancel_exception == true ? @trip_route.trip_cancel_status : '',
      planned_eta: @trip_route.employee_log_planned_eta&.in_time_zone("Kolkata")&.strftime("%H:%M").to_s,
      wait_time: wait_time
    }

  end

  private 

  def driver_name
    if @trip&.driver&.f_name.blank?
      ''
    else
      @trip&.driver&.f_name + ' ' + @trip&.driver&.l_name
    end
  end

end
