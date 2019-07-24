class Reports::ReportUtilizationDatatable
  def initialize(trip_group = nil)
    @trip_group = trip_group
  end

  def as_json(options = {})
    {
        :data => data
    }
  end

  def data
    parameters = get_params
    {
       :date => @trip_group.first,
       :vehicles_deployed => parameters[:cars],
       :total_available_capacity => parameters[:seats],
       :total_employees_transported => parameters[:employees],
       :utilization => "#{parameters[:utilization].round(0)}%"
    }
  end

  private
  # get params from all used cars
  def get_params
    trips = @trip_group.last
    seats = employees = 0
    trips.each do |trip|
      seats += trip.vehicle.seats
      employees += trip.employee_trips.count
    end
    {
        :cars => trips.count,
        :seats => seats,
        :employees => employees,
        :utilization=> (employees.to_f/seats.to_f) * 100
    }
  end


end
