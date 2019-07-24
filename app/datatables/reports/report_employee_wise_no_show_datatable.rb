class Reports::ReportEmployeeWiseNoShowDatatable
  include ReportsHelper
  def initialize(employee_id, trip)
    @employee_id = employee_id
    @trip = trip
  end

  def as_json(options = {})
    {
        data: data
    }
  end

  def data
    {
      employee_id: @employee_id,
      employee_name: @trip.first.employee_name,
      total_rides: @trip.size,
      no_shows: @trip.select { |x| x.employee_trip_status == "missed" }.size
    }
  end
end
