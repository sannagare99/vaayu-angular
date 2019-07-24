require 'services/trip_validation_service'

class EmployeeTripsController < TripValidationController
  skip_before_action :authenticate_user!, :only => [:share]
  before_action :set_trip, only: [:update, :destroy, :share, :remove_passenger]
  before_action :protect_destroy, only: :destroy

  def index
    respond_to do |format|
      format.html
      format.json { render json: EmployeeTripsDatatable.new(view_context, current_user)}
    end
  end

  def unique_shifts
    @employee = EmployeeTrip.find(params[:employee_trip]).employee
    all_shifts = @employee.shifts
    check_in_shifts_object = []
    check_in_shifts = []
    check_out_shifts_object = []
    check_out_shifts = []
    
    all_shifts.each do |shift|
      start_shift_time = Time.strptime(shift.start_time, "%H:%M").strftime("%I:%M %p")
      end_shift_time = Time.strptime(shift.end_time, "%H:%M").strftime("%I:%M %p")
      # start_hour = shift.start_time.split(":").first.to_i
      # start_minute = shift.start_time.split(":").second.to_i
      # end_hour = shift.end_time.split(":").first.to_i
      # end_minute = shift.end_time.split(":").second.to_i
      # start_time_format = 'AM'
      # end_time_format = 'AM'
      # if start_hour > 12
      #   start_hour = start_hour - 12
      #   start_time_format = 'PM'
      # end
      # if end_hour > 12
      #   end_hour = end_hour - 12
      #   end_time_format = 'PM'        
      # end

      # start_shift_time = start_hour.to_s + ":" + start_minute.to_s + " " + start_time_format
      # end_shift_time = end_hour.to_s + ":" + end_minute.to_s + " " + end_time_format

      if !check_in_shifts.include? shift.start_time
        check_in_shifts.push(shift.start_time)              
        check_in_shifts_object.push({'label': start_shift_time, 'value': start_shift_time})
      end
      if !check_out_shifts.include? shift.end_time
        check_out_shifts.push(shift.end_time)
        check_out_shifts_object.push({'label': end_shift_time, 'value': end_shift_time})
      end
    end
    render :json => {'check_in_shifts': check_in_shifts_object, 
                     'check_out_shifts': check_out_shifts_object 
                   }
  end

  def first_shift
    startDate = Time.zone.parse(params['startDate']) unless params['startDate'].blank?
    first_shift = EmployeeTrip
             .where(:status => ['upcoming', 'unassigned', 'reassigned'])
             .where(:date => startDate..startDate.end_of_day)
             .order('employee_trips.date ASC')
             .first
    if first_shift.nil? || first_shift.blank?
      @response = {
        :trip_type => 'check_in'
      }
    else
      @response = {
        :trip_type => first_shift.trip_type,
        :bus_rider => first_shift.bus_rider,
        :trip_time => first_shift.date
      }  
    end
    
    render :json => @response
  end

  def update    
    respond_to do |format|
      if @employee_trip.update({date: @employee_trip.get_related_trip(trip_params[:datetime])})
        employee_trip_array = []
        employee_trip_array.push(@employee_trip)
        format.json { render json: EmployeeTripDatatable.new(@employee_trip, employee_trip_array, "", "", current_user), status: :ok, location: @employee_trip }
      else
        format.json { render json: @employee_trip.json_messages, status: :unprocessable_entity }
      end
    end    
  end

  def destroy

  end

  def create_trip_rosters
    all_employee_trips = params['employee_trips_array']

    is_manual = true

    @response = {
      :success => true,
      :message => ''
    }

    error_trips = []

    EmployeeTrip.transaction do
      all_employee_trips.each do |et|
        #Update the route order in employee trips
        all_employee_trips[et].each_with_index do |e, i|
          employee_trip = EmployeeTrip.lock.find_by_prefix(e)
          employee_trip.update!(:route_order => i)
        end
        employee_trips = EmployeeTrip.where(id: all_employee_trips[et])
        existing_clusters = employee_trips.map(&:employee_cluster_id)
        if existing_clusters.count == all_employee_trips[et].count && existing_clusters.uniq.count == 1 && !existing_clusters.first.nil?
          employee_cluster = EmployeeCluster.find(existing_clusters.first)
        else
          employee_cluster = EmployeeCluster.create(date: employee_trips.first.date)
          employee_trips.each do |employee_trip|
            employee_trip.update(employee_cluster: employee_cluster)
          end
        end

        @trip = Trip.new(:employee_trip_ids_with_prefix=>all_employee_trips[et])
        @trip.current_user = current_user
        @trip.lock!
        @trip.site = @trip.employee_trips.first.employee.site
        @trip.bus_rider = @trip.employee_trips.first.bus_rider
        @trip.is_manual = is_manual
        @trip.employee_cluster = employee_cluster
        #Check if we are trying to make a trip for bus and non bus employees
        is_bus_rider = @trip.employee_trips.first.bus_rider
        create_trip = true

        @trip.employee_trips.each_with_index do |employee_trip, i|
          if is_bus_rider != employee_trip.bus_rider
            error_trips.push(all_employee_trips[et])
            create_trip = false
          end
        end
        if !@trip.save && create_trip
          error_trips.push(all_employee_trips[et])
        end
      end
    end

    if !error_trips.blank?
      @response = {
        :success => false,
        :message => @trip.errors.full_messages.to_sentence,
        :error_trips => error_trips
      }
    else
      # Save the cluster id to ensure this trip comes as a cluster for next week
      # zone_id = 0
      
      # ec = EmployeeCluster.create(date: @trip.employee_trips.first.date)
      # @trip.employee_trips.each do |et|
      #   # Save this cluster id
      #   et.update!(:employee_cluster => ec)
      # end
    end
    render :json => @response
  end

  def auto_cluster_trips
    employee_trips = EmployeeTrip.find(params['ids'])
    employee_trips.each do |employee_trip|
      employee_trip.set_zone
    end
    render json: {:success => true}, status: 200
  end

  def auto_clustering_via_service
    render json: :ok
  end

  def get_clusters
    @clusters = EmployeeTripClustersDatatable.new(view_context, current_user).empl_trips
    respond_to do |format|
      format.html
      format.json { render json: EmployeeTripClustersDatatable.new(view_context, current_user, @clusters)}
      format.xlsx {
        render xlsx: 'get_clusters', filename: 'clusters.xlsx'
      }
    end
  end

  def cancel_trip_request
    employee_trips = EmployeeTrip.find(params['ids'])
    result = {json: {}, status: :ok}
    begin
      EmployeeTrip.destroy(employee_trips)
    rescue
      result = {json: 'Sorry we can not cancel this trip request', status: '400'}
    end
    respond_to do |format|
      format.json {render result}
    end
  end

  # get Ad Hoc trip requests
  def employee_trip_change_requests
    respond_to do |format|
      format.html
      format.json { render json: TripChangeRequestsDatatable.new(view_context, current_user)}
    end
  end

  # change employee trip request (Ad Hoc)
  def trip_change_request_response
    result = {json: {}, status: :ok}
    # begin
    trip_change_requests = TripChangeRequest.find(params['ids'])
    if params['type'] == 'approve'
      trip_change_requests.each {|request| request.approve!}
    else
      trip_change_requests.each {|request| request.decline!}
    end
    # rescue
    #   result = {json: 'Something wrong', status: '400'}
    # end
    respond_to do |format|
      format.json {render result}
    end
  end

  #share trip
  def share
    get_location
    @trip = @employee_trip.trip
  end

  def trips
    employee = Employee.find(params[:id])
    trips = EmployeeTrip.trips_by_range(employee, params[:range_from], params[:range_to])
    render json: trips, status: 200
  end

  def schedule_trip
    @employee = Employee.find(params[:id])
    @schedule = @employee.employee_schedules
    @current_week_employee_trips = []
    @new_employee_trips = []
    14.times { @new_employee_trips << EmployeeTrip.new }
    range_from, range_to = (Time.now.beginning_of_week - 1.day).strftime("%Y-%m-%d"), (Time.now.end_of_week - 1.day).strftime("%Y-%m-%d")
    @current_week_trips = EmployeeTrip.trips_by_range(@employee, range_from, range_to)
    # @sites = @employee.employee_company.sites.select("id,name").map {|x| [x.name, x.id]}
    @sites = []
    @sites.push([@employee.site.name, @employee.site.id])
    @sites
    @all_shifts = @employee.shifts.to_json.html_safe
  end

  def schedule_trip_update
    return_data = {}
    @employee = Employee.find(params[:id])
    return_data[:status] = 400 and raise RuntimeError unless params[:employee].present?
    return_data[:status] = 400 and raise RuntimeError if params[:employee][:check_in_attributes].blank? || params[:employee][:check_out_attributes].blank?

    EmployeeTrip.create_or_update(@employee, employee_trip_params)
    flash[:notice] = 'Employee Trips are successfully updated'
    return_data[:message] = "Employee Trips are successfully updated"
    return_data[:status] = 200
  rescue RuntimeError
    response[:message] = "Invalid parameters"
  ensure
    render json: return_data, status: return_data[:status]
  end

  def remove_passenger
    employee_cluster = @employee_trip.employee_cluster
    @employee_trip.update!({
      :zone => nil,
      :cluster_error => nil,
      :is_clustered => false,
      :trip_id => nil,
      :employee_cluster_id => nil
    })

    if employee_cluster.employee_trips.empty?
      employee_cluster.destroy
      employee_cluster = nil
    end

    @et = EmployeeTrip.where(:employee_cluster_id => params['employee_cluster_id']).where(:date => @employee_trip.date)

    ids = []
    @et.each do |e|
      ids.push(e.id)
    end

    ret = check_if_valid_trip(ids, @employee_trip.trip_type)
    if ret != "passed"
      employee_cluster.update!(error: ret) if employee_cluster
    else
      employee_cluster.update!(error: nil) if employee_cluster
    end

    #Check if all are bus or non bus trips
    # is_bus_rider = @et.first&.bus_rider
    # @et.each do |employee_trip|
    #   if is_bus_rider != employee_trip.bus_rider
    #     employee_cluster.update!(error: 'Bus and Non Bus Employees cannot be clustered together') if employee_cluster
    #   end
    # end

    render json: {:success => true}, status: 200
  end

  def add_passengers
    respond_to do |format|
      format.html
      format.json { render json: EmployeeTripsAddPassengersDatatable.new(view_context)}
    end
  end

  def add_passengers_submit    
    employee_trips = EmployeeTrip.find(params['ids'])
    employee_trips.each do |employee_trip|
      employee_trip.update!(:employee_cluster_id => params['employee_cluster_id'], :is_clustered => true)
    end

    @et = EmployeeTrip.where(:employee_cluster_id => params['employee_cluster_id']).where(:date => employee_trips.first.date)

    employee_cluster = EmployeeCluster.find(params['employee_cluster_id'])

    ids = []
    @et.each do |e|
      ids.push(e.id)
    end

    ret = check_if_valid_trip(ids, employee_trips.first.trip_type)
    if ret != "passed"
      employee_cluster.update!(error: ret)
    else
      employee_cluster.update!(error: nil)
    end

    #Check if all are bus or non bus trips
    # is_bus_rider = @et.first&.bus_rider
    # @et.each do |employee_trip|
    #   if is_bus_rider != employee_trip.bus_rider
    #     employee_cluster.update!(:error => "Bus and Non Bus Employees cannot be clustered together")
    #   end
    # end

    # Recalculate the sequence of the trips for the cluster
    @response = TripValidationService.get_sorted_routes(ids)

    if @response[:sorted_employee_trip_ids].present?
      @response[:sorted_employee_trip_ids].each_with_index do |et, i|
        et = EmployeeTrip.find(et)
        et.update(:route_order => i)
      end
    end

    if @response[:female_exception].present?
      employee_cluster.update!(error: 'Female Exception')
    elsif @response[:error].present?
      employee_cluster.update!(error: 'Female exception managed by resequencing')
    end

    render json: {:success => true}, status: 200    
  end

  def set_exception_status
    params[:exception_status_mapping].each do |trip_route|
      TripRoute.update(trip_route, {:status => params[:exception_status_mapping][trip_route]['exception_status']})
      EmployeeTrip.update(params[:exception_status_mapping][trip_route]['employee_trip_id'], {:status => params[:exception_status_mapping][trip_route]['exception_status']})
    end
  end

  private

  def set_trip
    @employee_trip = EmployeeTrip.find_by_prefix(params[:id])
  end

  def get_location
    @location = params[:lat].blank? || params[:lng].blank? ? {} : {:lat => params[:lat], :lng => params[:lng]}
  end

  def trip_params
    trip_id = params['id']
    params['trip'] = params['data'][trip_id]
    params.require(:trip).permit!
  end

  def employee_trip_params
    params.require(:employee).permit!
  end

  def protect_destroy
    if employee_trip.trip.present? && ['active', 'completed'].include?(self.trip.status)
      employee_trip.unassign!
      return false
    end
  end
end
