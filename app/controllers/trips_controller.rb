require 'services/google_service'

class TripsController < ApplicationController
  before_action :is_guard_configuration_enabled, only: [:add_guard_to_trip, :guards_list]
  before_action :set_trip, only: [:show, :employee_trips, :update_employee_trips, :get_drivers, :assign_driver, :assign_driver_submit, :unassign_driver_submit, :complete_with_exception, :complete_with_exception_submit, :assign_driver_exception, :book_ola_uber, :book_ola_uber_submit, :add_guard_to_trip, :trip_details, :annotate_trip]
  after_action :сheck_trips_status, only: :update_employee_trips

  def index
    @ingest_job = IngestJob.new
    respond_to do |format|
      format.html
      format.json { render json: TripRostersDatatable.new(view_context, current_user)}
    end
  end

  def create
    @trip = Trip.new(:employee_trip_ids_with_prefix=>params['ids'])
    @trip.site = @trip.employee_trips.first.employee.site
    @trip.bus_rider = @trip.employee_trips.first.bus_rider

    #Check if we are trying to make a trip for bus and non bus employees
    is_bus_rider = @trip.employee_trips.first.bus_rider
    @trip.employee_trips.each do |employee_trip|
      if is_bus_rider != employee_trip.bus_rider
        @response = {
            :success => false,
            :message => "Cannot create trip for bus and non employees together"
        }
        render :json => @response
        return
      end
    end
    if @trip.save
      # Save the cluster id to ensure this trip comes as a cluster for next week
      zone_id = 0
      @trip.employee_trips.each do |et|
        if zone_id == 0
          zone_id = EmployeeTrip.where(date: et.date).where(trip_type: et.trip_type).maximum(:zone)
          if !zone_id
            zone_id = 1
          else
            zone_id = zone_id + 1
          end        
        end
        # Save this zone id
        et.update!(:zone => zone_id)
      end

      flash[:notice] = 'Trip was successfully created'
      redirect_to trips_path
    else
      @response = {
          :success => false,
          :message => @trip.errors.full_messages.to_sentence
      }
      render :json => @response
    end
  end

  def show
    @employee_trips = EmployeeTrip.joins(:trip_route).where(:trip => @trip).order('trip_routes.scheduled_route_order ASC')
    get_trip_data(@employee_trips)

    @driver = @trip.driver
    @vehicle = @trip.vehicle

    @notification = Notification.where(:trip => @trip).where(:resolved_status => false, 
      :message => ['panic','employee_no_show','driver_no_show','car_break_down',
        'car_broken_down','car_ok_pending','car_broke_down_trip',
        'not_on_board','still_on_board','driver_didnt_accept_trip',
        'trip_should_start','vehicle_ok','female_first_or_last_in_trip',
        'employee_changed_trip','trip_not_started',
        'female_exception_driver_unassigned',
        'female_exception_female_removed', 
        'car_break_down_driver_unassigned', 
        'on_leave', 'on_leave_trip','out_of_geofence_check_in',
        'out_of_geofence_drop_off','out_of_geofence_driver_arrived',
        'out_of_geofence_missed', 'out_of_geofence_check_in_site',
        'out_of_geofence_drop_off_site','out_of_geofence_driver_arrived_site',
        'out_of_geofence_missed_site', 'female_exception_route_resequenced', 
        'employee_no_show_approved']).order('sequence DESC').order('created_at DESC').first

    #unless params[:notification_id].blank?
    #  @notification = Notification.find(params[:notification_id])
    #  @notification_text = I18n.t("devise_token_auth.passwords.sended", email: @email)
    #end
  end

  def update

  end

  def drivers_timeline
    # TODO: shouldn't the user be logged in? 
    # figure out which roles and restrict
    trip_status = ['assigned', 'assign_request_expired', 'assign_requested', 'active', 'canceled', 'completed']
    female = params[:female]
    logistics_company_id = params[:logistics_company_id]
    cabs = [0, 1]
    if params[:cabs] == 'true'
      cabs = [0]
    end
    if logistics_company_id == '0'
      trips = Trip.includes({:driver => [:user, :vehicle]}, :recent_unresolved_notification).where(:scheduled_date => Time.now.advance(minutes: -210)..Time.now.advance(minutes: +210)).where(:status => trip_status).where(:bus_rider => cabs)
    else
      trips = Trip.includes({:driver => [:user, :vehicle]}, :recent_unresolved_notification).where('trips.scheduled_date BETWEEN ? AND ?', Time.now.advance(minutes: -135), Time.now.advance(minutes: +135)).where('trips.status' => trip_status).where('trips.bus_rider' => cabs).where('drivers.logistics_company_id = ?', logistics_company_id).references(:driver)
    end    
    grouped_trips = trips.select { |t| !t.driver.nil? }.group_by(&:driver).to_a
    grouped_trips.sort_by! { |trip_entry|
      # trip_entry[1].map { |t|
      #   t.recent_unresolved_notification&.id || 0
      # }.max
      sequence = -1
      date = Time.now - 1.year

      trip_entry[1].each do |t|
        recent_sequence = -1
        recent_date = Time.now - 1.year

        if t.recent_unresolved_notification.present?
          if t.recent_unresolved_notification&.sequence >= sequence
            sequence = t.recent_unresolved_notification&.sequence
            if t.recent_unresolved_notification&.created_at >= date
              date = t.recent_unresolved_notification&.created_at
            end
          end
        end
      end

      if sequence < 2
        [0, 0, trip_entry[0].full_name]
      else
        [sequence, date, trip_entry[0].full_name]
      end
    }.reverse!

    grouped_trips.each do |grouped_trip|
      grouped_trip[1].each do |trip|
        if female == 'true'
          if !trip.check_if_female_in_trip
            grouped_trip[1].delete(trip)
          end
        end
      end
    end

    respond_to do |format|
      format.json {render json: ::DriverTimelinePresenter.new(grouped_trips) }
    end
  end

  def trip_details
    @trip_detail = {}
    @trip = Trip.find_by_id(params[:id])    
    @trip_detail = trip_data(@trip)
    render json: @trip_detail, status: 200
  end

  def trip_data(trip)
    {
       "DT_RowId" => "#{Trip::DATATABLE_PREFIX}-#{@trip.id}",
       :status => trip.status,
       :date => trip.scheduled_date&.strftime("%m/%d/%Y").to_s,
       :id => trip.id,
       :trip_type => trip.trip_type,
       :start_date => trip.start_date,
       :approximate_duration => trip.scheduled_approximate_duration.minutes,
       :approximate_distance => trip.scheduled_approximate_distance / 1000,
       :driver_name => trip&.driver&.f_name.to_s,
       :driver_l_name => trip&.driver&.l_name.to_s,
       :licence => trip&.driver&.licence_number.to_s,
       :plate_number => trip&.vehicle&.plate_number.to_s,
       :trip_routes => emloyee_status(trip),
       :site_lat => trip.employee_trips.first&.employee&.site&.latitude,
       :site_lng => trip.employee_trips.first&.employee&.site&.longitude,
       :cancel_status => trip.cancel_status,
       :completed_date => trip.completed_date&.strftime("%I:%M%p").to_s,
       :scheduled_end_date => trip.approximate_trip_end_date&.strftime("%I:%M%p").to_s,
       :direction => trip.trip_type.humanize,
       :is_first_female_pickup => trip.check_in? && @trip&.trip_routes&.order("scheduled_route_order").first&.employee&.gender == "female",
       :is_last_female_drop => trip.check_out? && @trip.trip_routes.order("scheduled_route_order").last.employee&.gender == "female",
       :is_guard_required => trip.is_guard_required?
    }
  end

  def emloyee_status(trip)
    employee_trips = EmployeeTrip.joins(:trip_route).where(:trip => trip).order('trip_routes.scheduled_route_order ASC')
    employee_trips.map do |employee_trip|
      employee_trip.trip_route&.get_employee_info
    end
  end  

  def update_employee_trips
    if params['action_type'] == 'delete'
      @empl_trips = EmployeeTrip.find(params['ids'])
      trip = @empl_trips.first.trip
      @empl_trips.each {|employee_trip| employee_trip.remoe_employee_trip(current_user) }
      # trip.employee_trips.each { |et| et.remoe_employee_trip } if trip.is_first_female_pickup
      # TODO: Fix this guard flow
      # trip.delete_if_first_female if trip.assign_requested?
      ret = trip.resequence_if_required

      trip.resolve_female_first_or_last_notification
      #unassign driver if female exception could not be solved with resequencing
      if ret[:female_exception]
        if !trip.created?
          trip.unassign_driver_due_to_female_exception!
        end
      end

      if ret[:resequence_trip]
        render :json => { :success => 'ok', :error => "Female first/last exception managed by re-sequencing"}
      else
        render :json => { :success => 'ok' }
      end      
    elsif params['action_type'] == 'delete_all' 
      @trip.employee_trips.each {|employee_trip| employee_trip.remoe_employee_trip(current_user) }
    end
  end

  def get_drivers
    @drivers = Driver.eager_load(:logistics_company, :vehicle, :user).where(:site => @trip.site)
    @on_duty_drivers = @drivers.on_duty

    # @active_drivers = @on_duty_drivers.where('trips.status' => ['active'])
    @available_drivers = @on_duty_drivers

    if @trip.check_in?
      trip_route = @trip.trip_routes.order('scheduled_route_order ASC').where.not(status: [:canceled, :missed ]).first
      start_lat = trip_route.scheduled_start_location[:lat]
      start_lng = trip_route.scheduled_start_location[:lng]
    elsif @trip.check_out?
      trip_route = @trip.trip_routes.order('scheduled_route_order ASC').first
      start_lat = @trip.site.location[0]
      start_lng = @trip.site.location[1]
    end

    @match_drivers = []
    @drivers_match_eta = []

    @driver_status = {}
    @driver_last_paired_vehicle = {}

    driver_ids = ""
    @drivers.each do |driver|
      next if !driver.id
      driver_ids = "#{@driver_ids},#{driver.id}"
      @driver_status[driver.id] = driver.status

      if driver.vehicle.present?
        @driver_last_paired_vehicle[driver.id] = driver.vehicle.plate_number
        if driver.vehicle.status != 'vehicle_ok'
          @driver_status[driver.id] += ", Car Broke Down"
        end        
      end
    end

    driver_ids[0] = ''

    @status = Trip.find_by_sql("select count(*) as count, driver_id, status from trips where status in ('active', 'assigned', 'assign_requested', 'assign_request_expired') group by status, driver_id")

    @status.each do |trip|
      next if !trip.driver_id
      @driver_status[trip.driver_id] = '' if @driver_status[trip.driver_id].blank?
      if @driver_status[trip.driver_id] != "Car Broke Down"
        @driver_status[trip.driver_id] += ", #{trip.count} #{trip.status.humanize}"
      end
    end

    @driver_status[0] = ''
    @driver_status[1] = ''

    @last_vehicle = Trip.find_by_sql("select tt.*, rr.plate_number as plate_number from 
      (select driver_id, max(planned_date) as latest_date, vehicle_id from trips 
        group by driver_id) as tt left join vehicles as rr on tt.vehicle_id = rr.id where vehicle_id is not null")


    @last_vehicle.each do |lv|
      next if !lv.driver_id
      if @driver_last_paired_vehicle[lv.driver_id].blank?
        @driver_last_paired_vehicle[lv.driver_id] = lv.plate_number
      end
    end

    if start_lng.present? || start_lat.present?
      #Fetch the best matching drivers
      @match_drivers = @trip.match_drivers(@available_drivers, start_lat, start_lng)
      # @match_drivers = []
      #Find ETA for Drivers
      @drivers_match_eta = @trip.get_driver_eta(@match_drivers, start_lat, start_lng)
    end


    @emp_count = @trip.employee_trips.count

    #@active_drivers = Driver.eager_load(:trips).where(:site => @trip.site).where('trips.status' => ['active', 'assigned', 'assign_requested']).on_duty
    #@drivers = @drivers - @active_drivers
    render 'trips/assign_driver'
  end

  def assign_driver
    @driver = Driver.find(params['driver_id'])
    @vehicle = @driver.vehicle

    if params['last_paired_vehicle'].present?
      @last_paired_vehicle = Vehicle.where('plate_number' => params['last_paired_vehicle'])&.first&.id
    end

    if @vehicle.present? && @trip.employee_trips.count > @vehicle&.seats
      render :json => { :error => 'To many people to one car' }
      return
    else
      @employee_trips = EmployeeTrip.joins(:trip_route).where(:trip => @trip).order('trip_routes.scheduled_route_order ASC')
      get_trip_data(@employee_trips)
      if params[:exception] == 'true'
        @exception = 1
      else
        @exception = 0
      end
      render 'show_trip_on_dispatch'
    end
  end

  def assign_driver_submit    
    if @trip.driver.present?
      #Send unassign driver notification to already assigned driver in case of change driver
      @trip.unassign_driver!

      #Resolve driver didn't start notification
      @notification = Notification.where(:trip => @trip, :message => 'trip_should_start', :resolved_status => false)
      @notification.each do |notification|
        notification.update!(resolved_status: true)
      end
    end

    driver = Driver.find(params['driver_id'])

    error_message = ""
    error_type = ""
    error = false

    if !driver.on_duty? || driver.vehicle.blank?
      error = true
      error_type = "change_driver"
      error_message = "The Trip can’t be assigned: Driver is now Off Duty. Please check with this Driver or choose a different one"
    end

    if params['last_paired_vehicle'].present?
      @last_paired_vehicle = Vehicle.where('id' => params['last_paired_vehicle']).first

      if @last_paired_vehicle.present?
        if @last_paired_vehicle != driver.vehicle
          error = true
          if driver.vehicle.seats < @trip.employee_trips.count            
            error_type = "change_driver"
            error_message = "Trip can’t be assigned: Driver is now driving a different Vehicle (#{driver.vehicle.plate_number}) with less capacity."
          else
            error_type = "continue"
            error_message = "ALERT: The Driver is now driving a different Vehicle (#{driver.vehicle.plate_number}). Do you want to Continue?."
          end
        end
      end
    end

    if error
      render :json => {:error => true, :error_type => error_type, :error_message => error_message}
    else
      if @trip.update(:driver => driver, :vehicle => driver.vehicle)
        if @trip.assign_driver!
          render :json => { :success => 'Driver successfully assigned' }
        else
          render :json => { :error => 'Something wrong' }
        end
      end
    end
  end

  def auto_assign_driver
    trips = Trip.joins(:employee_cluster).where(status: :created)
    assignment_summary = {
      errors: [],
      errors_count: 0,
      total_trips_count: trips.count,
    }
    trips.each do |trip|
      driver = trip.employee_cluster.driver
      if driver&.off_duty?
        assignment_summary[:errors_count] += 1
        assignment_summary[:errors] << {
          trip_id: trip.id,
          error: 'Driver off duty'
        }
      elsif trip.is_guard_required?
        assignment_summary[:errors_count] += 1
        assignment_summary[:errors] << {
          trip_id: trip.id,
          error: 'Trip requires guard assignment'
        }
      elsif !driver.nil?
        trip.update(driver: driver, vehicle: driver.vehicle)
        unless trip.assign_driver!
          assignment_summary[:errors_count] += 1
          assignment_summary[:errors] << {
            trip_id: trip.id,
            error: "Failed to assign driver: #{driver.user.full_name}"
          }
        end
      else
        assignment_summary[:errors_count] += 1
        assignment_summary[:errors] << {
          trip_id: trip.id,
          error: 'Driver not provisioned'
        }
      end
    end
    render json: { data: assignment_summary, success: 'Driver assigned automatically' }
  end

  def auto_assign_guard
    trips = Trip.where(:status => 'created').order('scheduled_date ASC')
    assignment_summary = {
      errors: [],
      errors_count: 0,
      total_trips_count: 0,
    }

    employee_ids = []
    #Fetch all guards
    @all_guards = Employee.guard.eager_load(:user)
    @employees = @all_guards - Employee.guard.eager_load(:user).joins(:employee_trips).where('employee_trips.status in ("current", "trip_created")').uniq

    if @employees.present?
      @employees.each do |et|
        employee_ids.push(et.id)
      end
    end

    trips.each do |trip|
      if trip.is_guard_required?
        assignment_summary[:total_trips_count] += 1
        if employee_ids.blank?
          assignment_summary[:errors_count] += 1
          assignment_summary[:errors] << {
            trip_id: trip.id,
            error: 'Guard not available'
          }  
          next      
        end

        trip.add_guard_to_trip(employee_ids.shift)
        # employee_ids = employee_ids[0]
      end
    end

    render json: { data: assignment_summary, success: 'Guard assigned automatically' }
  end

  def assign_driver_exception
    @driver_id = params['driver_id']
    if params[:book_ola] == 'true'
      @book_ola = 1
    else
      @book_ola = 0
    end    
    render 'complete_with_exception'
  end

  def unassign_driver_submit
    if @trip.unassign_driver!    
      if @trip.update(:driver => nil, :vehicle => nil)
        render :json => { :success => 'Driver successfully assigned' }
      else
        render :json => { :error => 'Something wrong' }
      end
    end
  end

  def employee_trips
    @employee_trips = EmployeeTrip.joins(:trip_route).where(:trip => @trip).where.not('trip_routes.status = "canceled"').order('trip_routes.scheduled_route_order ASC')
    @address_mapping = {}
    @employee_trips.each do |et|
      if @address_mapping.has_key? et&.pick_up_address
        @address_mapping[et&.pick_up_address] << @address_mapping[et&.employee.id]
      else
        @address_mapping[et&.pick_up_address] = [@address_mapping[et&.employee.id]]
      end
    end
  end

  def complete_with_exception
    unless params[:notification_id].blank?
      @notification = Notification.find(params[:notification_id])
    end
    @selected_trip = Trip.find(params[:id])
    @drivers = []
    if !@selected_trip.driver_id.blank?
      @selected_driver = Driver.find(@selected_trip.driver_id)
      @drivers.push(@selected_driver)
      @other_drivers = Driver.where(:site => @selected_trip.site).where.not(:id => @selected_driver.id)
      @other_drivers.each do |driver|
        @drivers.push(driver)
      end      
    else
      @drivers = Driver.where(:site => @selected_trip.site)
    end

    @employee_trips = EmployeeTrip.joins(:trip_route).where(:trip => @trip).order('trip_routes.scheduled_route_order ASC')

    if params[:book_ola] == 'true'
      @book_ola = 1
    else
      @book_ola = 0
    end
    render 'complete_with_exception'
  end

  def search_driver
    name = params['search'].split(' ')
    if name[0].present? && name[1].present?
      query = 'users.f_name like "%' + name[0] + '%" and users.l_name like "%' + name[1] + '%"'
    else
      query = 'users.f_name like "%' + params['search'] + '%" or users.l_name like "%' + params['search'] + '%"'
    end
    @selected_trip = Trip.find(params[:id])    
    
    @drivers_json = []
    @drivers = Driver.joins(:user).where(:site => @selected_trip.site).where(query)
    @drivers.each do|driver|
      # driver.f_name = driver.user.f_name
      # driver.l_name = driver.user.l_name
      @driver = {
        :name => "#{driver.user.f_name} #{driver.user.l_name}",
        :plate_number => driver.paired_vehicle,
        :id => driver.id
      }

      @drivers_json.push(@driver)
    end

    render :json => {:drivers => @drivers_json}
  end
  
  def complete_with_exception_submit    
    # Mark the notification as resolved
    if !params[:ride_cost].blank?
      @trip.cancel_complete_trip
      @trip.update(:ola_fare => params[:ride_cost])
      render :json => { :success => 'Trip updated successfully' }
      return
    end

    unless params[:notification_id].blank?
      @notification = Notification.find(params[:notification_id])
      @notification.update!(resolved_status: true)
    end

    #assign driver in case of assign with exception
    unless params[:driver_id].blank?
      driver = Driver.find(params['driver_id'])

      if driver.vehicle.present?
        @trip.update(:driver => driver, :vehicle => driver.vehicle)
      else
        @trip.update(:driver => driver)
      end
    end

    if params[:book_ola] == 'true'
      @trip.book_ola_uber!
      @trip.update(:book_ola => true)
    else
      #Update the status of the trip as cancelled
      @trip.cancel_complete_trip
    end

    if @trip.update(:cancel_status => params[:status])
      render :json => { :success => 'Trip canceled successfully' }
    else
      render :json => { :error => 'Something wrong' }
    end    
  end

  def book_ola_uber
    @employee_trips = EmployeeTrip.joins(:trip_route).where(:trip => @trip).order('trip_routes.scheduled_route_order ASC')

    @employee_trips.each do |employee_trip|
      if employee_trip.trip_route.canceled? || employee_trip.trip_route.missed? || employee_trip.trip_route.completed?
        next
      end
      if !employee_trip.trip_route.on_board?
        employee_trip.trip_route.update!(cab_start_location: employee_trip.destination)
      else
        # Fetch latest location of the driver
        @trip_locations = @trip.trip_location.order("id DESC").first

        if @trip_locations.present?
          # Fetch location name from lat lng
          results = GoogleService.new.reverse_geocode(@trip_locations.location)
          employee_trip.trip_route.update!(cab_start_location: results[1][:formatted_address])
        end
      end
    end
    render 'book_ola_uber'
  end

  def book_ola_uber_submit
    total_cost = 0
    params['employee_data'].each_with_index do |val, index|
      @trip_route = TripRoute.where(id: val[1]["id"]).first
      if @trip_route.present?
        #Find the total cost of ola uber booking
        total_cost = total_cost + val[1]["cost"].to_i
        @trip_route.update!(cab_fare: val[1]["cost"], cab_driver_name: val[1]["driver_name"], cab_licence_number: val[1]["licence_number"], cab_start_location: val[1]["location"])
        if val[1]["driver_name"].present? && val[1]["licence_number"].present?
          @user = User.employee.where(id: @trip_route.employee_trip.employee.user_id).first
          if @user.present?
            driver_name = val[1]["driver_name"]
            cab_licence_number = val[1]["licence_number"]
            SMSWorker.perform_async(@user.phone, ENV['OPERATOR_NUMBER'], "The operator has assigned a Cab for you. #{driver_name} will arrive at your pickup location in #{cab_licence_number} soon.")
          end
        end
      end
    end
    
    if (TripRoute.where(trip: @trip).where(cab_fare: nil).where.not(:status => 'canceled').present?)
      @trip.update(:book_ola => true)
      @trip.book_ola_uber!
      #Create a notification for book ola uber
      @notification = Notification.where(:trip => @trip, :message => 'book_ola_uber', :resolved_status => false, :reporter => 'Moove System').first
      if @notification.blank?
        Notification.create!(:trip => @trip, :driver => @trip.driver,  :message => 'book_ola_uber', :resolved_status => false, :new_notification => true, :reporter => 'Moove System').send_notifications
      end
    else
      @trip.cancel_complete_trip
      @trip.update(:ola_fare => total_cost)
      @notification = Notification.where(:trip => @trip, :message => 'book_ola_uber', :resolved_status => false).first
      if @notification.present?
        @notification.update!(resolved_status: true)
      end
      render :json => { :success => 'Trip updated successfully' }
    end

  end

  def annotate_trip    
    reporter = "Operator: #{current_user.full_name}"
    @notification = Notification.where(:trip => @trip, :message => "annotate_trip", :remarks => "#{params[:subject]} - #{params[:body]}").first
    if @notification.blank?
      Notification.create!(:trip => @trip, :driver => nil, :employee => nil, :message => "annotate_trip", :remarks => "#{params[:subject]} - #{params[:body]}", :resolved_status => true,:new_notification => true, :reporter => reporter).send_notifications
    end
    @trip.resolve_panic_notification
  end

  def guards_list
    @trip_id = params[:trip_id]
    @all_guards = Employee.guard.eager_load(:user)
    @employees = @all_guards - Employee.guard.eager_load(:user).joins(:employee_trips).where('employee_trips.status in ("current", "trip_created")').uniq
  end

  def add_guard_to_trip
    @trip.add_guard_to_trip(params[:employee_id])
    render json: true, status: 200
  end

  private

  def set_trip
    @trip = Trip.find_by_prefix(params[:id])
  end

  # Check if need to cancel trip
  def сheck_trips_status
    if @trip.employee_trips.empty?
      @trip.cancel!
    end
  end

  def get_trip_data(employee_trips)
    @address_mapping = {}
    @eta_mapping = {}
    @status_mapping = {}
    @status_length_mapping = {}
    @colspan_mapping = {}
    @rowspan_mapping = {}
    @last = nil
    
    last_checked = ''
    reset = false
    employee_trips.each do |et|
      if @address_mapping.has_key? et&.trip_route&.scheduled_route_order
        @address_mapping[et&.trip_route&.scheduled_route_order] << et
      else
        @address_mapping[et&.trip_route&.scheduled_route_order] = [et]
      end
    end

    @address_mapping.each do |address, ets|
      height = 0
      total = ets.size
      last = ets&.first&.employee&.id
      @eta_mapping[last] = ets.size

      ets.each do |et|

        
        if et.trip_route.status == 'missed' || et.trip_route.status == 'canceled'
          if et.trip_route.status == 'canceled' && !et.trip_route.cancel_exception?
            @status_mapping[et&.employee.id] = 'Canceled'                      
          elsif et.trip_route.status == 'canceled' && et.trip_route.cancel_exception? && et.trip_route.cab_fare.blank?
            @status_mapping[et&.employee.id] = 'CWE'
          elsif et.trip_route.status == 'canceled' && et.trip_route.cancel_exception? && !et.trip_route.cab_fare.blank?
            @status_mapping[et&.employee.id] = 'Booked Ola/Uber'
          elsif et.trip_route.status == 'missed'
            @status_mapping[et&.employee.id] = 'No Show'
          end
          @rowspan_mapping[et&.employee&.id] = 1
          @colspan_mapping[et&.employee&.id] = 1
          if !@last.nil?
            @rowspan_mapping[last] = height
          end
          last = nil
          height = 0
          total = total - 1
        else
          height = height + 1
          if last.nil?
            last = et&.employee&.id
          end
          @rowspan_mapping[et&.employee&.id] = 0
          @rowspan_mapping[last] = height
        end



        # if et.trip_route.status != 'canceled' && et.trip_route.status != 'missed'
        #   if reset
        #     last_checked = et&.employee.id
        #   end
        #   if @eta_mapping[last_checked].nil?
        #     @eta_mapping[last_checked] = 1
        #   else
        #     @eta_mapping[last_checked] = @eta_mapping[last_checked] + 1  
        #   end
        #   reset = false
        # else
        #   if et.trip_route.status == 'canceled' && !et.trip_route.cancel_exception?
        #     @status_length_mapping[et&.employee.id] = 1
        #     @status_mapping[et&.employee.id] = 'Canceled'                      
        #   elsif et.trip_route.status == 'canceled' && et.trip_route.cancel_exception? && et.trip_route.cab_fare.blank?
        #     @status_length_mapping[et&.employee.id] = 1
        #     @status_mapping[et&.employee.id] = 'CWE'
        #   elsif et.trip_route.status == 'canceled' && et.trip_route.cancel_exception? && !et.trip_route.cab_fare.blank?
        #     @status_length_mapping[et&.employee.id] = 1
        #     @status_mapping[et&.employee.id] = 'Booked Ola/Uber'
        #   elsif et.trip_route.status == 'missed'
        #     @status_length_mapping[et&.employee.id] = 1
        #     @status_mapping[et&.employee.id] = 'No Show'
        #   end
        #   if !reset
        #     last_checked = et&.employee.id
        #   end    
        #   @eta_mapping[last_checked] = 1
        #   reset = true
        # end
      end
    end
  end

  def is_guard_configuration_enabled
    render json: 'Sorry, you have not permissions', status: '403' and return if ENV["ENALBE_GUARD_PROVISIONGING"] != "true"
  end
end
