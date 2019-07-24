class Reports::ReportNoShowAndCancellationDatatable
  include ReportsHelper
  def initialize(date, trip_group = nil)
    # @trip_group = trip_group
    @trips = trip_group
    @date = date
  end

  def as_json(options = {})
    {
        :data => data
    }
  end

  def data
    # @trips_data = trips_data
    {
       :date => @date.first,
       :shift_time => @date[1],
       :direction => @date.last.titleize,
       :manifested => @trips.size,
       :no_shows => @trips.select(&:missed?).size
    }
  end

  private

  # get params from all used cars
  def trips_data
    trips = @trip_group.last.uniq
    total_employees = rostered = canceled = no_shows = 0
    @date = Date.strptime(@trip_group.first, '%m/%d/%Y')
    total_employees = EmployeeTrip.where('date > ? and date < ?', @date, @date + 1).count

    trips.each do |trip|
      #Fetch all the trip routes
      trip_routes = TripRoute.where(:trip => trip)
      trip_routes.each do |trip_route|
        canceled += 1 if trip_route.canceled?
        no_shows += 1 if trip_route.missed?
      end
      rostered += trip.employee_trips.count


    end

    begin
      @trips_data = {
          :total_employees => total_employees,
          :rostered => rostered,
          :canceled => canceled,
          :no_shows => no_shows,
      }
    rescue
      # binding.pry
    end
  end


end



