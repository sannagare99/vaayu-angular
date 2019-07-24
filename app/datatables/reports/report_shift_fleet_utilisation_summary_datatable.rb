class Reports::ReportShiftFleetUtilisationSummaryDatatable
  include ReportsHelper
  def initialize(info, trip)
    @trip = trip
    @info = info
  end

  def as_json(options = {})
    {
        data: data
    }
  end

  def data
    {
      date: @info.first.to_datetime&.strftime("%d-%m-%Y"),
      shift_time: @info.second,
      direction: @info.last.humanize,
      vehicle_deployed: @trip.map(&:id).compact.uniq.size,
      total_capacity: @trip.uniq { |trip| trip.id }.sum(&:seats),
      planned_capacity: @trip.size,
      actual_capacity: @trip.select { |trip| trip.status == "completed" }.size,
      load_factor: ""
    }
  end
end
