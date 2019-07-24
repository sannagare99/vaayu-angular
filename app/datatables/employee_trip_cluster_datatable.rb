class EmployeeTripClusterDatatable
  def initialize(group = nil, employee_trips = nil, num, max_seats, current_user, nodal)
    @group = group
    @employee_trips = employee_trips
    @num = num
    @max_seats = max_seats
    @current_user = current_user
    @nodal = nodal
  end

  def as_json(options = {})
    {
        :data => data
    }
  end

  def data
    trip_id = ""
    if @employee_trips.first.check_in?
      trip_id = "#{@employee_trips.first.date.strftime("%Y %m %d")} - (To Work)"
    else
      trip_id = "#{@employee_trips.first.date.strftime("%Y %m %d")} - (To Home)"
    end

    {
       "DT_RowId" => "#{EmployeeTrip::DATATABLE_PREFIX}-#{@num}",
       :trip_id => trip_id,
       :date => @employee_trips.first.date.strftime("%m/%d/%Y %H:%M"),
       :orig_date => @employee_trips.first.date.strftime("%Y-%m-%d %H:%M:%S"),
       :site => @employee_trips.first.employee.site.name,
       :site_lat => @employee_trips.first.employee.site.latitude,
       :site_lng => @employee_trips.first.employee.site.longitude,
       :trip_type => @employee_trips.first.trip_type.humanize,
       :size => @employee_trips.size,
       :max_seats => @max_seats,
       :employee_trips => employee_trips_data,
       :current_user => @current_user,
       :zone => @employee_trips.first.zone,
       :cluster_error => @employee_trips.first.employee_cluster.error,
       :bus_rider => @employee_trips.first.bus_rider,
       :bus_route_name => @employee_trips.first.employee.bus_trip_route&.bus_trip&.route_name,
       :employee_cluster_id => @employee_trips.first.employee_cluster_id,
    }
  end

  private
  def employee_trips_data
    empl_trips = []
    @employee_trips.each do |et|
      empl_trips.push(get_info(et))
    end
    empl_trips
  end

  def get_info(trip)
    {
       "DT_RowId" => "#{EmployeeTrip::DATATABLE_PREFIX}-#{trip.id}",
       :trip_id => trip.id,
       :employee_name => trip.employee.user.f_name,
       :employee_id => trip.employee.employee_id,
       :employee_l_name => trip.employee.user.l_name,
       :phone => trip.employee.user.phone,
       :sex => trip.employee.gender.to_s.first.capitalize,
       :status => trip.status,
       :date => trip.date.strftime("%m/%d/%Y %H:%M"),
       :site => trip.employee.site.name,
       :geohash => trip.employee.geohash,
       :eta => trip.eta,
       :message => "",
       :route_order => trip.route_order,
       :address => trip.pick_up_address(@nodal),
       :area => trip.employee.landmark || '--'
    }.merge(trip.pick_up_lat_lng(@nodal))
  end
end
