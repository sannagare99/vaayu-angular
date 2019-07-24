class Reports::ReportVehicleDeploymentDatatable
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
      date: get_date_time(@trip.first&.strftime("%Y-%m-%d"), @trip.first&.strftime("%H:%M")),
      ba_name: @trip[1],
      shift_time: @trip[2],
      trip_type: @trip[3].titleize,
      vehicle_deployed: @trip.last
    }
  end
end
