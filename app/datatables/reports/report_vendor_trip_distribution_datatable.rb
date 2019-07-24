class Reports::ReportVendorTripDistributionDatatable
  include ReportsHelper
  def initialize(trip, trips)
    @trip = trip
    @trips = trips
  end

  def as_json(options = {})
    {
        data: data
    }
  end

  def data
    {
      date: @trip.first.to_datetime&.strftime("%d-%m-%Y"),
      shift: @trip.second,
      direction:  @trip.third.humanize,
      vendor:  @trip.last,
      no_of_trips:  @trips.length,
      planned_mileage:  sprintf("%.1f", @trips.map(&:planned_approximate_distance).sum / 1000.0),
      actual_mileage:  sprintf("%.1f", @trips.map(&:planned_approximate_distance).sum / 1000.0)
    }
  end
end
