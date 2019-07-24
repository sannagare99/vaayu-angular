class Reports::ReportOtdDatatable
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
      trip_id: @trip.id,
      status: @trip.status.titleize,
      driver_name: @trip.driver_name.titleize,
      vehicle: @trip.vehicle_no,
      vendor_name: @trip.vendor_name,
      shift_time: get_date_time(@trip.date, @trip.shift_time, "time"),
      driver_arrival_at_site: driver_arrival_at_site,
      scheduled_depature_time: schdeuled_depature_time&.strftime("%d-%m-%Y %H:%M"),
      actual_depature_time: actual_first_pickup
    }
  end

  private

  def actual_first_pickup
    max_date = @trip.trip_routes.map(&:on_board_date).compact.max
    return "-" if max_date.nil?
    to_minutes(max_date - schdeuled_depature_time)
  end

  def driver_arrival_at_site
    max_date = @trip.trip_routes.map(&:driver_arrived_date).compact.max
    return "-" if max_date.nil?
    to_minutes(max_date - @trip.scheduled_date)
  end

  def schdeuled_depature_time
    buffer_time = 10.minutes
    @trip.scheduled_date + buffer_time
  end

  def to_minutes(dat)
    dat.present? ? "#{(dat/60.0).round}" : dat
  end
end



