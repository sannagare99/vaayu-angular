class Reports::ReportShiftWiseNoShowDatatable
  include ReportsHelper
  def initialize(info, trip)
    @info = info
    @trip = trip
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
      total_employees: @trip.size,
      no_shows: @trip.select { |trip| trip.status == "missed" }.size
    }
  end
end
