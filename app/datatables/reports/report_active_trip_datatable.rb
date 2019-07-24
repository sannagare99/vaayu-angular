class Reports::ReportActiveTripDatatable
  def initialize(trip = nil)
    @trip = trip
  end

  def as_json(options = {})
    {
        :data => data
    }
  end

  def data
    {
       "DT_RowId" => "#{Trip::DATATABLE_PREFIX}-#{@trip.id}",
       :id => @trip.id,
       :driver => @trip.driver.full_name,
       :trip_roster => "#{@trip.start_date&.strftime("%m/%d/%Y")} - #{@trip.id}",
       :phone => @trip.driver.phone,
       :trip_status => @trip.status,
       :employees => get_employees
    }
  end

  private
  def get_employees
    employee_trips = EmployeeTrip.joins(:trip_route).where(:trip => @trip).order('trip_routes.scheduled_route_order ASC')
    employee_trips.map do |employee_trip|
      employee_trip.trip_route&.get_employee_info
    end
  end

end
