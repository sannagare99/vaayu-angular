class Reports::ReportDriversTripSummaryDatatable
  include ReportsHelper
  def initialize(group_info, trip)
    @group_info = group_info
    @trip = trip
  end

  def as_json(options = {})
    {
        data: data
    }
  end

  def data
    {
      date: @group_info.first.to_datetime&.strftime("%d-%m-%Y"),
      driver_name: @group_info.second,
      vehicle: @group_info.last,
      total_trips: @trip.size,
      mileage: sprintf("%.1f", get_mileage),
      mileage_per_trip: sprintf("%.1f", get_mileage / @trip.size)
    }
  end

  private

  def get_mileage
    mileage = @trip.sum(&:scheduled_approximate_distance)
    return 0.0 if mileage.nil?
    mileage / 1000.0
  end
end
