class Reports::ReportOtaDatatable
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
      date: @trip.date.present? ? @trip.date.to_datetime&.strftime("%d-%m-%Y") : @trip.employee_trip_date&.strftime("%d-%m-%Y"),
      trip_id: @trip.id,
      status: @trip.status.titleize,
      driver: @trip.driver_name,
      vehicle: @trip.vehicle_no,
      ba: @trip.ba,
      shift_time: get_date_time(@trip.employee_trip_date&.strftime("%Y-%m-%d"), @trip.employee_trip_date&.strftime("%H:%M"), "time"),
      scheduled_end_time: @trip.scheduled_date&.strftime("%d-%m-%Y %H:%M"),
      actual_end_time: @trip.completed_date&.strftime("%d-%m-%Y %H:%M"),
      delta_in_arrival_at_site: delta_in_arrival,
      planned_first_pickup_time: @trip.planned_date&.strftime("%d-%m-%Y %H:%M"),
      actual_arrival_time_for_first_pickup: acutal_arrival_time,
      actual_first_pickup_time: actual_first_pickup
    }
  end

  private

  def delta_in_arrival
    to_minutes(@trip.completed_date - @trip.employee_trip_date) rescue ""
  end

  def acutal_arrival_time
    to_minutes(@trip.trip_routes.first&.driver_arrived_date - @trip.planned_date) rescue ""
  end

  def actual_first_pickup
    to_minutes(@trip.trip_routes.first&.on_board_date - @trip.trip_routes.first&.driver_arrived_date) rescue ""
    # max_date = @trip.trip_routes.map(&:on_board_date).compact.max
    # return "-" if max_date.nil?
    # to_minutes(max_date - @trip.planned_date)
  end

  def to_minutes(dat)
    dat.present? ? "#{(dat/60.0).round}" : dat
  end
end
