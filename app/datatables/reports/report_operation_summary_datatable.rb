class Reports::ReportOperationSummaryDatatable
  include ActionView::Helpers::NumberHelper
  include ReportsHelper

  def initialize(date, trips)
    @trips = trips
    @date = date
  end

  def as_json(options = {})
    {
        :data => data
    }
  end

  def data
    {
       date: @date&.strftime("%d-%m-%Y"),
       total_trips: @trips.length,
       trips_catered_to: @trips.select(&:completed?).size,
       # trips_canceled: @trips.select(&:canceled?).size,
       trips_canceled: @trips.select{ |tr| tr.canceled? or tr.cancel_status == "trip cancelled" }.size,
       drivers: @trips.map(&:driver_id).compact.uniq.size,
       total_distance: @trips.map(&:scheduled_approximate_distance).sum / 1000.0,
       distance_per_trip: (@trips.map(&:scheduled_approximate_distance).sum.to_f/@trips.size) / 1000.0,
       duration_per_trip: (@trips.map { |x| x.real_duration.to_i }.sum.to_f/@trips.size)
    }
  end
end



