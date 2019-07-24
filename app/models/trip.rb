require 'services/google_service'
require 'services/trip_validation_service'

class Trip < ApplicationRecord 
  extend AdditionalFinders
  include AASM
  include TripScopes
  include Models::Trip::TripRouteExtension

  belongs_to :site
  belongs_to :vehicle
  belongs_to :driver
  belongs_to :employee_cluster

  has_many :employee_trips
  has_one :recent_notification, -> { order(resolved_status: :asc, sequence: :desc, id: :desc).limit(1) }, class_name: 'Notification'
  has_one :recent_unresolved_notification, -> { where(resolved_status: false).order(sequence: :desc, id: :desc).limit(1) }, class_name: 'Notification'
  has_many :employees, through: :employee_trips
  has_many :trip_routes, -> { ordered }, dependent: :destroy
  has_many :trip_route_exceptions, through: :trip_routes
  has_many :notifications, dependent: :delete_all
  has_many :trip_location, dependent: :delete_all

  scope :by_day, ->(date) do
    where(:scheduled_date => date.beginning_of_day..date.end_of_day)
  end

  attr_accessor :current_user

  # Check in and check out time were set
  scope :active_trip, -> { where(status: :active)}

  scope :by_period, ->(start_date, end_date) do
    where(:start_date => start_date..end_date)
  end

  delegate :name, to: :site, prefix: :site

  DATATABLE_PREFIX = 'trip'
  ONBOARD_PASSENGER_TIME = 0
  TIME_TO_ARRIVE = 10
  DRIVER_ASSIGN_REQUEST_EXPIRATION = 3.minutes

  MAXIMUM_TRIP_DURATION = 90
  MAXIMUM_TRIP_DISTANCE = 45 # in km
  MAX_EMPLOYEES_IN_A_TRIP = 4

  before_create :set_trip_type

  after_create :create_or_update_route
  after_create :change_employee_trip_status
  after_create :notify_if_female_in_trip
  after_create :notify_operator_created_trip
  after_create :resolve_female_removed_notification

  validate :employees_are_not_in_trip_yet, on: :create

  validate :is_valid_trip, on: :create

  serialize :planned_start_location, Hash
  serialize :planned_end_location, Hash
  serialize :scheduled_start_location, Hash
  serialize :scheduled_end_location, Hash

  serialize :start_location, Hash
  serialize :route, Array

  MAX_DISTANCE_AWAY_IN_KM = 100.0
  RAD_PER_DEG             = 0.017453293

  Rkm     = 6371           # radius in kilometers, some algorithms use 6367
  Rmeters = Rkm * 1000     # radius in meters

  enum trip_type: [:check_in, :check_out]
  aasm column: :status, whiny_transitions: false do
    state :created, :initial => true
    state :ingested
    state :assigned
    state :canceled

    state :active
    state :completed

    # Operator assign driver; request sent
    state :assign_requested
    # Driver declined request
    state :assign_request_declined
    # Driver does not approve request in N minutes
    state :assign_request_expired

    event :uningest, after: :change_employee_trip_status do
      transitions to: :created
    end

    # state :panic ??
    event :cancel do
      transitions :to => :canceled, after: [:resolve_all_trip_notifications]
    end

    event :assign_driver do
      transitions :from => [:created], to: :assign_requested, after: [ :enqueue_request_expiration_job, :notify_driver_about_assignment, :resolve_trip_state_notifications, :add_operator_assigned_trip_notification, :trip_assigned_get_location, :resolve_trip_state_notifications, :save_assign_trip_date ]
    end

    #Unassign a driver and change the trip state back to created
    event :unassign_driver do
      transitions :from => [:assign_requested, :assign_request_expired, :assigned], to: :created, after: [:notify_employee_trips_changed, :notify_driver_about_unassignment, :unassign_driver_info]
    end

    event :unassign_driver_due_to_female_exception do
      transitions :from => [:assign_requested, :assign_request_expired, :assigned], to: :created, after: [:notify_employee_trips_changed, :notify_driver_about_unassignment_due_to_security, :add_notification_unassign_driver_due_to_female_exception, :unassign_driver_info]
    end

    event :unassign_driver_due_to_car_broke_down do
      transitions :from => [:assign_requested, :assign_request_expired, :assigned, :active], to: :created, after: [:notify_employee_trips_changed, :notify_driver_about_unassignment_due_to_security, :add_notification_unassign_driver_due_to_car_broke_down, :unassign_driver_info]
    end    

    # event :assign_driver_request_expired do
    #   transitions from: :assign_requested, to: :assign_request_expired, after: :unassign_driver
    # end

    event :assign_driver_accept_restarted do
      transitions :from => [:assign_request_expired], to: :assign_requested, after: [ :enqueue_request_restart_expiration_job, :resolve_trip_state_notifications]
    end

    event :assign_driver_request_expired do
      transitions from: :assign_requested, to: :assign_request_expired, after: :resolve_trip_state_notifications
    end

    # Driver accepted a trip
    event :assign_request_accepted do
      transitions :from => [:assign_requested, :assign_request_expired], to: :assigned, after: [ :notify_employees_about_upcoming_trip, :save_trip_accept_date, :resolve_trip_state_notifications, :add_driver_accepted_trip_notification ]
    end

    # Driver declined a trip
    event :assign_request_declined do
      transitions from: :assign_requested, to: :assign_request_declined, after: [ :create_notify_not_accepted_manifest, :resolve_trip_state_notifications ]
    end

    # Driver started a trip
    event :start_trip do
      transitions from: :assigned, to: :active, after: [ :save_start_trip_data, :set_employee_trips_as_started, :schedule_notify_employee_trip_started, :notify_employee_trips_changed, :resolve_trip_state_notifications, :add_driver_start_trip_notification ]
    end

    event :book_ola_uber do
      transitions :from => [:created, :assigned, :active, :assign_requested, :assign_request_expired], to: :active, after: [:notify_employees_about_ola_uber, :notify_driver_about_ola_uber, :resolve_trip_state_notifications ]
    end

    event :completed do
      transitions from: :active, to: :completed, after: [ :save_completed_trip_data, :create_notify_completed, :notify_employee_trips_changed, :resolve_all_trip_notifications ]
    end

  end

  def trip_site
    self.site
  end

  # Calculate overall trip rating
  def average_rating
    avg = employee_trips.average(:rating)
    avg.nil? ? nil : avg.round(2)
  end

  # Verify that employee are not used in trips
  def employees_are_not_in_trip_yet
    employee_trip_to_create = EmployeeTrip.where(id: self.employee_trip_ids).where.not(trip_id: nil)
    unless employee_trip_to_create.blank?
      employee_trip_to_create.each do |employee_trip|
        errors.add(:base, "#{employee_trip.employee_full_name} is already in trip")
      end
    end
  end

  # Verify that trip is a valid trip
  def is_valid_trip
    employee_trip_to_create = EmployeeTrip.where(id: self.employee_trip_ids)

    employee_trips_array = []
    employee_trip_to_create.each do |e|
      employee_trips_array.push(e.id.to_s)
    end

    #ret = check_if_valid_trip(employee_trips_array, self.trip_type)
    #if ret != "passed"
    #  errors.add(:base, "#{ret}")        
    #end
  end

  def employee_trip_ids_with_prefix=(params)
    ids = params.map do |id|
      id.match(/\d+/)[0].to_i
    end
    self.employee_trip_ids = ids
  end

  def site_location
    site.location
  end

  def site_location_hash
    site.location_hash
  end

  # Number of passengers
  def passengers
    employee_trips.size
  end

  # @TODO: fetch actual next pickup time
  def next_pickup_date
    scheduled_date
  end

  # Time when the last passenger will be out of car
  def approximate_trip_end_date
    self.scheduled_date + self.scheduled_approximate_duration.minutes
  end

  # Time when the last passenger will be out of car
  def planned_trip_end_date
    self.planned_date + self.planned_approximate_duration.minutes
  end

  def month
    scheduled_date.strftime('%m')
  end

  def week
    scheduled_date.strftime('%W')
  end

  def day
    scheduled_date.strftime('%d')
  end

  def data
    start_date.strftime('%m/%d/%Y') unless start_date.blank?
  end

  def scheduled_data
    scheduled_date.strftime('%m/%d/%Y') unless scheduled_date.blank?
  end

  def trip
    id
  end

  # Is trip cannot be proceed by driver
  def suspended?
    trip_routes.has_unresolved_suspending_exceptions.any?
  end

  # Send push notification update to all employee trips screens in app
  def notify_employee_trips_changed

    employee_trips.each do |employee_trip|
      if employee_trip.canceled? || employee_trip.missed?
        #Do not send a notification in case of canceled or missed trip
        next
      end
      # if employee_trip.status == 'completed'
      #   @user = User.employee.where(id: employee_trip.employee.user_id).first
      #   if @user.present?
      #     SMSWorker.perform_async(@user.phone, ENV['OPERATOR_NUMBER'], 'Your trip has been completed. Please use the MOOVE App to rate this trip, and optionally provide additional feedback.');
      #   end        
      # end

      if employee_trip.status == 'trip_created'
        data = { id: employee_trip.id, data: {id: employee_trip.id, push_type: :operator_deleted_trip} }
        PushNotificationWorker.perform_async(employee_trip.employee.user_id, :operator_deleted_trip, data, :user)
      end
      data = { id: employee_trip.id, data: {id: employee_trip.id, push_type: :trip_updated} }
      PushNotificationWorker.perform_async(employee_trip.id, :trip_updated, data, :employee_trip)
    end

  end

  def notify_driver_about_ola_uber
    if driver.present?
      @user = User.driver.where(id: driver.user_id).first
      if @user.present?
        SMSWorker.perform_async(@user.phone, ENV['OPERATOR_NUMBER'], 
          'The operator has booked OLA / Uber for your trip. Please contact operator for more info.')
      end    
      data = {driver_id: driver.user_id, data: {driver_id: driver.user_id, push_type: :driver_ola_uber} }
      PushNotificationWorker.perform_async(
          driver.user_id,
          :driver_ola_uber,
          data)        
    end
  end

  def notify_employees_about_ola_uber
    employee_trips.each do |employee_trip|
      if employee_trip.canceled? || employee_trip.missed?
        #Do not send a notification in case of canceled or missed trip
        next
      end
      if employee_trip.status != 'completed'
        @user = User.employee.where(id: employee_trip.employee.user_id).first
        if @user.present?
          SMSWorker.perform_async(@user.phone, ENV['OPERATOR_NUMBER'], 'You will be travelling in an OLA / Uber cab. Please call your Operator for more info.');
        end
        data = { id: employee_trip.id, data: { id: employee_trip.id, push_type: :employee_ola_uber } }
        PushNotificationWorker.perform_async(employee_trip.employee.user_id, :employee_ola_uber, data, :user)
      end
    end    
  end

  # Handle aasm event failed messages
  def aasm_event_failed(event_name, old_state)
    message = case [ event_name, old_state ]
                when [ :start_trip, :active ]
                  'The trip has already been started'
                when [ :assign_request_accepted, :assigned ]
                  'The trip has already been accepted'
                else
                  "Bad transition from #{old_state} to #{event_name}"
              end
    
    self.errors.add(:base, :aasm, message: message)
  end
  
  def self.trip_logs_csv(options = {}, report_params = {})
    row = 0
    from_reports = report_params[:from_reports].present? ? report_params[:from_reports] : false
    trips = report_params[:trips].nil? ? all : report_params[:trips]
    CSV.generate(options) do |csv|        
      trips.each do |trip|
        trip.trip_routes.each do |trip_route|
          if row == 0
            csv << trip.get_trip_logs_data(trip, trip_route, from_reports).keys.map { |x| x.to_s.camelize.to_sym }
            row = row + 1
          end
          csv << trip.get_trip_logs_data(trip, trip_route, from_reports).values
          break
        end
      end    
    end
  end

  def self.employee_logs_csv(options = {}, report_params = {})
    row = 0
    trips = report_params[:trips].nil? ? all : report_params[:trips]
    CSV.generate(options) do |csv|        
      trips.each do |trip|
        trip.trip_routes.each do |trip_route|
          if row == 0
            csv << trip.get_employee_logs_data(trip, trip_route).keys
            row = row + 1
          end
          csv << trip.get_employee_logs_data(trip, trip_route).values
        end
      end    
    end
  end

  def get_employee_logs_data(trip, trip_route)
    delta_time = ""
    status_names = { on_board: "Picked Up", missed: "No Show", canceled: "Canceled", completed: "Picked Up" }
    if trip.driver.present?
      @user_driver = User.driver.where(id: trip.driver.user_id).first
      if @user_driver.present?
        driver_name = @user_driver.full_name
        driver_number = trip.driver.aadhaar_mobile_number
        driver_moove_number = @user_driver.phone
      end
    end
    if trip_route.employee_trip.employee.present?
      @user_employee = User.employee.where(id: trip_route.employee_trip.employee.user_id).first
      if @user_employee.present?
        employee_name = @user_employee.full_name
        emp_id = trip_route.employee_trip.employee.employee_id
        employee_moove_number = @user_employee.phone
      end
    end
    if trip.vehicle.present?
      plate_number = trip.vehicle.plate_number
    end

    if trip_route.missed?
      noshow = "no show"
    end
    if trip.assign_request_expired_date.present?
      assign_request_expired_date = trip.assign_request_expired_date.in_time_zone("Kolkata").strftime("%m/%d/%Y %H:%M").to_s
    end

    if trip.trip_accept_time.present?
      trip_accept_time = trip.trip_accept_time.in_time_zone("Kolkata").strftime("%m/%d/%Y %H:%M").to_s
    end

    # {
    #     :PlannedDate  => trip.planned_date.in_time_zone("Kolkata").strftime("%m/%d/%Y %H:%M").to_s,
    #     :ScheduledDate  => trip.scheduled_date.in_time_zone("Kolkata").strftime("%m/%d/%Y %H:%M").to_s,
    #     :type => trip.trip_type,
    #     :PlannedApproximateDuration => trip_route.planned_distance,
    #     :PlannedApproximateDistance => trip_route.planned_duration,
    #     :ScheduledApproximateDuration => trip_route.scheduled_distance,
    #     :ScheduledApproximateDistance => trip_route.scheduled_duration,
    #     :RealDuration => trip.real_duration,
    #     :TripCompletedDate => trip.completed_date,
    #     :TripStartLocation => trip.start_location,
    #     :Status => trip_route.status,
    #     :RouteNo => trip_route.scheduled_route_order,
    #     :Shift => "Shift Number",
    #     :VehicleNo => plate_number,
    #     :DriverName => driver_name,
    #     :DriverNumber => driver_number,
    #     :DriverMooveNumber => driver_moove_number,
    #     :Reason => "Reason",
    #     :EmployeeName => employee_name,
    #     :EmpId => emp_id,
    #     :EmployeeMooveNumber => employee_moove_number,
    #     :MooveManifestNumber => trip.scheduled_date.in_time_zone("Kolkata").strftime("%Y/%m/%d").to_s + '-' + trip.id.to_s,
    #     :PlannedPickupTime => trip_route.approximate_driver_arrive_date,
    #     :NoShow => noshow,
    #     :AcceptanceTime => trip.trip_accept_time,
    #     :TripStartTime => trip.start_date,
    #     :PickupLocationReachTime => trip_route.driver_arrived_date,
    #     :CheckInTime => trip_route.on_board_date,
    #     :DropOffTime => trip_route.completed_date,
    #     :TripCompletedTime => trip.real_duration,
    #     :StillInCar => "",
    #     :PanicRaised => "",
    #     :Remarks => "",
    #     :MLLTripId => "",
    #     :DriverArrivedLocation => trip_route.driver_arrived_location,
    #     :CheckInLocation => trip_route.check_in_location,
    #     :DropOffLocation => trip_route.drop_off_location,
    #     :MissedLocation => trip_route.missed_location,
    #     :TripAcceptTime => trip_accept_time,
    #     :TripRequestExpiredDate => assign_request_expired_date,
    #     :cancel_status => trip.cancel_status
    # }
    if trip.check_in? && trip.completed_date
      delta_time = ((trip.completed_date&.in_time_zone("Kolkata") - trip_route.employee_trip.date.in_time_zone("Kolkata")) / 60).to_i
    end

    if trip.check_out? && trip_route.driver_arrived_date
      delta_time = ((trip_route.driver_arrived_date&.in_time_zone("Kolkata") - trip_route.employee_trip.date.in_time_zone("Kolkata")) / 60).to_i
    end

    wait_time = trip_route.driver_arrived_date.present? && trip_route.on_board_date.present? ? Time.at(trip_route.on_board_date-trip_route.driver_arrived_date).utc.strftime("%M").to_i : ""

    {
      :Date => trip_route.employee_trip.date.in_time_zone("Kolkata").strftime("%d-%m-%Y").to_s,
      :TripId => trip.id,
      status: trip.cancel_status.blank? ? trip.status.humanize : 'CWE',
      :ShiftTime => trip_route&.employee_trip.date.in_time_zone("Kolkata").strftime("%H:%M").to_s,
      :Direction => trip_route&.employee_trip.trip_type.titleize,
      :RiderName => employee_name,
      :NotifiedETA => trip_route.approximate_driver_arrive_date&.in_time_zone("Kolkata")&.strftime("%H:%M").to_s,
      :IAmHere => trip_route.driver_arrived_date&.in_time_zone("Kolkata")&.strftime("%d-%m-%Y %H:%M").to_s,
      :PickUpTime => trip_route.on_board_date&.in_time_zone("Kolkata")&.strftime("%d-%m-%Y %H:%M").to_s,
      :DropOffTime => trip_route.completed_date&.in_time_zone("Kolkata")&.strftime("%d-%m-%Y %H:%M").to_s,
      :employee_status => status_names.keys.include?(trip_route.status.to_sym) ? status_names[trip_route.status.to_sym] : "",
      :ExceptionDetail => trip_route.cancel_exception == true ? trip.cancel_status : '',
      planned_eta: trip_route.employee_log_planned_eta&.in_time_zone("Kolkata")&.strftime("%H:%M").to_s,
      wait_time: wait_time
    }
  end

  def get_trip_logs_data(trip, trip_route, from_reports=false)
    delta_time = ""
    if trip.driver.present?
      @user_driver = User.driver.where(id: trip.driver.user_id).first
      if @user_driver.present?
        driver_name = @user_driver.full_name
        driver_number = trip.driver.aadhaar_mobile_number
        driver_moove_number = @user_driver.phone
      end
    end
    if trip_route.employee_trip.employee.present?
      @user_employee = User.employee.where(id: trip_route.employee_trip.employee.user_id).first
      if @user_employee.present?
        employee_name = @user_employee.full_name
        emp_id = trip_route.employee_trip.employee.employee_id
        employee_moove_number = @user_employee.phone
      end
    end
    if trip.vehicle.present?
      plate_number = trip.vehicle.plate_number
    end

    if trip_route.missed?
      noshow = "no show"
    end
    if trip.assign_request_expired_date.present?
      assign_request_expired_date = trip.assign_request_expired_date.in_time_zone("Kolkata").strftime("%m/%d/%Y %H:%M").to_s
    end

    if trip.trip_accept_time.present?
      trip_accept_time = trip.trip_accept_time.in_time_zone("Kolkata").strftime("%m/%d/%Y %H:%M").to_s
    end

    # {
    #     :PlannedDate  => trip.planned_date.in_time_zone("Kolkata").strftime("%m/%d/%Y %H:%M").to_s,
    #     :ScheduledDate  => trip.scheduled_date.in_time_zone("Kolkata").strftime("%m/%d/%Y %H:%M").to_s,
    #     :type => trip.trip_type,
    #     :PlannedApproximateDuration => trip_route.planned_distance,
    #     :PlannedApproximateDistance => trip_route.planned_duration,
    #     :ScheduledApproximateDuration => trip_route.scheduled_distance,
    #     :ScheduledApproximateDistance => trip_route.scheduled_duration,
    #     :RealDuration => trip.real_duration,
    #     :TripCompletedDate => trip.completed_date,
    #     :TripStartLocation => trip.start_location,
    #     :Status => trip_route.status,
    #     :RouteNo => trip_route.scheduled_route_order,
    #     :Shift => "Shift Number",
    #     :VehicleNo => plate_number,
    #     :DriverName => driver_name,
    #     :DriverNumber => driver_number,
    #     :DriverMooveNumber => driver_moove_number,
    #     :Reason => "Reason",
    #     :EmployeeName => employee_name,
    #     :EmpId => emp_id,
    #     :EmployeeMooveNumber => employee_moove_number,
    #     :MooveManifestNumber => trip.scheduled_date.in_time_zone("Kolkata").strftime("%Y/%m/%d").to_s + '-' + trip.id.to_s,
    #     :PlannedPickupTime => trip_route.approximate_driver_arrive_date,
    #     :NoShow => noshow,
    #     :AcceptanceTime => trip.trip_accept_time,
    #     :TripStartTime => trip.start_date,
    #     :PickupLocationReachTime => trip_route.driver_arrived_date,
    #     :CheckInTime => trip_route.on_board_date,
    #     :DropOffTime => trip_route.completed_date,
    #     :TripCompletedTime => trip.real_duration,
    #     :StillInCar => "",
    #     :PanicRaised => "",
    #     :Remarks => "",
    #     :MLLTripId => "",
    #     :DriverArrivedLocation => trip_route.driver_arrived_location,
    #     :CheckInLocation => trip_route.check_in_location,
    #     :DropOffLocation => trip_route.drop_off_location,
    #     :MissedLocation => trip_route.missed_location,
    #     :TripAcceptTime => trip_accept_time,
    #     :TripRequestExpiredDate => assign_request_expired_date,
    #     :cancel_status => trip.cancel_status
    # }
    if trip.check_in? && trip.completed_date
      delta_time = ((trip.completed_date&.in_time_zone("Kolkata") - trip_route.employee_trip.date.in_time_zone("Kolkata")) / 60).to_i
    end

    if trip.check_out? && trip_route.driver_arrived_date
      delta_time = ((trip_route.driver_arrived_date&.in_time_zone("Kolkata") - trip_route.employee_trip.date.in_time_zone("Kolkata")) / 60).to_i
    end    

    data = {
      :Date => trip_route.employee_trip.date.in_time_zone("Kolkata").strftime("%d-%m-%Y").to_s,
      :TripId => trip.id,
      :Driver => driver_name,
      :ShiftTime => trip_route&.employee_trip.date.in_time_zone("Kolkata").strftime("%H:%M").to_s,
      :Direction => trip_route&.employee_trip.trip_type.humanize,
      :ActualTime => trip.check_in? ? trip.completed_date&.in_time_zone("Kolkata")&.strftime("%H:%M")&.to_s: trip_route.driver_arrived_date&.in_time_zone("Kolkata")&.strftime("%H:%M")&.to_s,
      :TripAccepted => trip.trip_accept_time&.strftime("%d-%m-%Y %H:%M")&.to_s,
      :TripStarted => trip.start_date&.strftime("%d-%m-%Y %H:%M")&.to_s,
      :NumberOfRiders => trip.trip_routes.size,
      :Distance => sprintf("%.1f", (trip.scheduled_approximate_distance / 1000.0)),
      :Duration => trip.real_duration,
      :Status => trip.cancel_status.blank? ? trip.status.humanize : 'CWE',
      :ExceptionDetail => trip.cancel_status,
      :VehicleCapacity => trip.vehicle&.seats,
      :DeltaTime => delta_time,
      trip_assigned: notifications.operator_assigned_trip.first&.created_at&.strftime("%d-%m-%Y %H:%M")
    }
  end

  # Update trip route by factoring in driver current location
  def update_route(driver_lat, driver_lng)
    #Save the start location of the driver.
    self.update(start_location: {:lat => driver_lat.to_f, :lng => driver_lng.to_f})

    ScheduleUpdateTripDistanceDurationWorker.perform_async(self.id)

    # waypoints = female_filter_results

    # return if waypoints.empty? # for factorygirl test passing @TODO: remove later

    # if self.check_in?
    #   # Take the start location of the driver as origin
    #   origin = [driver_lat, driver_lng]
    #   destination = site_location
    # else
    #   further_waypoint = waypoints.shift
    #   origin = site_location
    #   destination = further_waypoint.employee_address      
    # end

    # # Take trip start time as the current time
    # trip_start_date = Time.now.in_time_zone(Time.zone)

    # route = GoogleService.new.directions(
    #     origin,
    #     destination,
    #     waypoints: waypoints.map{|et| et.employee_address},
    #     mode: 'driving',
    #     departure_time: trip_start_date.to_i,
    #     optimize_waypoints: ! waypoints.empty? # optimize if there are any waypoints
    # )
  
    # # reorder waypoints as google maps optimized them
    # reordered_waypoints = route.first[:waypoint_order].map{|i| waypoints[i]}

    # route_data = route.first[:legs]

    # if self.check_in?
    #   #remove first element from the route array as this corresponds to driver current location and first employee location
    #   route_data.shift      
    # else
    #   reordered_waypoints.push(further_waypoint)
    # end

    # #Fetch the previos trip routes
    # prev_trip_routes = self.trip_routes.order('scheduled_route_order ASC')

    # new_trip_routes = reordered_waypoints.each_with_index.map do |employee_trip, i|

    #   start_location = route_data[i][:start_location]
    #   end_location = route_data[i][:end_location]

    #   route_intr = GoogleService.new.directions(
    #       start_location,
    #       end_location,
    #       mode: 'driving',
    #       departure_time: trip_start_date.to_i,
    #   )
    #   new_route_data_intr = route_intr.first[:legs]

    #   prev_trip_routes[i].update({
    #       employee_trip: employee_trip,
    #       scheduled_route_order: i,
    #       scheduled_duration: (new_route_data_intr[0][:duration_in_traffic][:value].to_f / 60).ceil, #sec to min
    #       scheduled_distance:route_data[i][:distance][:value],
    #       scheduled_start_location: start_location,
    #       scheduled_end_location: end_location
    #   })
    # end

    # #update the scheduled distance and duration of the trip
    # update_trip_distance_duration

    #Check if any of the trip has been cancelled
    # prev_trip_routes.each do |trip_route|
    #   if trip_route.canceled?
    #     #In case any trip has been cancelled, update start and end location for that trip route
    #     trip_route.update_trip_route_start_end
    #   end
    # end
  end

  def set_trip_location(latlng, distance, speed, time = "")
    if time == ""
      time = Time.now.in_time_zone(Time.zone)
    end

    self.trip_location.create!({
      location: latlng,
      time: time,
      distance: distance,
      speed: speed 
    })
  end

  def cancel_complete_trip
    #Cancel each trip route in the trip
    self.employee_trips.each do |employee_trip|
      unless ['canceled', 'missed', 'completed'].include?(employee_trip.trip_route.status)
        if employee_trip.trip_route.present?
          employee_trip.trip_route.complete_with_exception
        end
        if employee_trip.present?
          employee_trip.trip_canceled!
        end
      end
    end
    #Mark the complete trip as canceled
    self.cancel!

    #Notification for Trip Completed with Exception
    if !Current.user.nil?
        reporter = "Operator: #{Current.user.full_name}"
      else
         reporter = "Operator:"
      end

    @notification = Notification.where(:trip => self, :driver => driver, :message => 'completed_with_exception').first

    if @notification.blank?
      Notification.create!(:trip => self, :driver => driver, :message => 'completed_with_exception', :new_notification => true, :resolved_status => true, :reporter => reporter).send_notifications
    end
    
    #Send a push notification to employees about employee trip changed
    notify_employee_trips_changed

    # Send a push notification to driver for trip cancel
    notify_driver_trip_cancel

    # Auto complete all notifications
    auto_resolve_notifications
  end

  def notify_employee_driver_trip_exception
    employee_trips.each do |employee_trip|
      if employee_trip.canceled? || employee_trip.missed? || employee_trip.completed?
        #Do not send a notification in case of canceled, missed trip or missed trip
        next
      end
      data = { id: employee_trip.id }
      data = data.merge({data: data})
      data[:data].merge!(push_type: :driver_trip_exception)
      data.merge!({notification: I18n.t("push_notification.driver_trip_exception")})
      PushNotificationWorker.perform_async(employee_trip.employee.user_id, :driver_trip_exception, data, :user)
    end
  end

  def resend_notity_driver_about_assignment
    self.update(assign_request_expired_date: Time.new + DRIVER_ASSIGN_REQUEST_EXPIRATION)
    self.renotify_driver_about_assignment

    #Send notification for reassignment
    Notification.create!(:trip => self, :driver => driver, :message => 'reassigned_trip', :new_notification => true, :resolved_status => true, :reporter => 'Moove System').send_notifications    
  end

  def add_guard_to_trip(employee_id)
    #Check if a guard is already present in the employee trips
    employee_trips.each do |et|
      return if et.employee.is_guard
    end
    et_param = employee_trips.first.attributes.symbolize_keys.slice(:site_id, :schedule_date, :date)
    et = EmployeeTrip.create(et_param.merge({trip_type: trip_type, employee_id: employee_id, trip_id: id}))
    et.added_to_trip!
    create_or_update_route

    #Resolve Guard Notification
    resolve_female_first_or_last_notification
    add_guard_notification
  end

  def add_guard_notification
    reporter = "Operator: #{Current.user.full_name}"

    Notification.create!(:trip => self, :driver => driver, :message => 'guard_added', :new_notification => true, :resolved_status => true, :reporter => reporter).send_notifications    
  end

  def resolve_female_first_or_last_notification
    @notification = Notification.where(:trip => self, :resolved_status => false, :message => ['female_first_or_last_in_trip', 'female_exception_driver_unassigned'])
    @notification.each do |notification|
      notification.update!(resolved_status: true)
    end
  end

  def is_female_first_or_last_in_trip?
    (check_in? && trip_routes.ordered.first.employee.female?) || (check_out? && trip_routes.ordered.last.employee.female?)
  rescue
    false
  end

  # Day shift time is from 0630 to 1930
  def is_guard_required?
    @employee_trip_ids = []
    @trip_routes = self.trip_routes.where.not(status: :canceled).order('scheduled_route_order ASC')

    return false if @trip_routes.blank?

    @trip_routes.each do |trip_route|
      @employee_trip_ids.push(trip_route.employee_trip.id)
    end

    TripValidationService.is_female_exception(@employee_trip_ids, self.trip_type)
  end

  #Get match drivers for this particular trip
  def match_drivers(drivers, start_lat, start_lng)
    drivers = drivers.sort do |driver1, driver2|
      # if self.check_in?
      #   trip_route = self.trip_routes.order('scheduled_route_order ASC').where.not(status: [:canceled, :missed ]).first
      #   start_lat = trip_route.scheduled_start_location[:lat]
      #   start_lng = trip_route.scheduled_start_location[:lng]
      # elsif self.check_out?
      #   trip_route = self.trip_routes.order('scheduled_route_order ASC').first
      #   start_lat = self.site.location[0]
      #   start_lng = self.site.location[1]
      # end

      driver_location_1 = driver1.user.current_location
      driver_location_2 = driver2.user.current_location

      driver_1_distance = 99999999
      driver_2_distance = 99999999
      if driver_location_1.present?
        driver_1_distance = haversine_distance(driver_location_1[:lat], driver_location_1[:lng], start_lat, start_lng) / 1000
      end


      if driver_location_2.present?
        driver_2_distance = haversine_distance(driver_location_2[:lat], driver_location_2[:lng], start_lat, start_lng) / 1000
      end

      driver_1_distance <=> driver_2_distance
    end 
   
    drivers.first(10)
  end

  # Send push notifications to each employee when the trip has been started
  def notify_employees_trip_started
    #Send notification to only first employee in case of check in
    if self.check_in?
      #Get the first valid trip route
      trip_route = self.trip_routes.order('scheduled_route_order ASC').where.not(status: [:canceled, :missed ]).first

      if trip_route.present?
        #Get the time taken to reach driver start location and first valid user pick up location
        start_location = self.start_location
        end_location = [trip_route.scheduled_start_location[:lat], trip_route.scheduled_start_location[:lng]]
        route = GoogleService.new.directions(
            start_location,
            end_location,
            mode: 'driving',
            avoid: 'tolls',
            departure_time: Time.now.in_time_zone('Chennai')
        )
        route_data = route.first[:legs]

        eta = Time.now.in_time_zone('Chennai') + (route_data[0][:duration_in_traffic][:value]).ceil
        eta = eta.strftime("%H:%M")

        notification_channel = Configurator.get_notifications_channel('send_notification_driver_start_trip')
        if notification_channel[:sms]
          @user = User.employee.where(id: trip_route.employee_trip.employee.user_id).first
          if @user.present?
            @user_driver = User.driver.where(id: driver.user_id).first
            SMSWorker.perform_async(@user.phone, ENV['OPERATOR_NUMBER'], @user_driver.full_name + ' is on the way to your pick-up location in ' + vehicle.colour + ' ' + vehicle.make + ' ' + vehicle.model + '(' + vehicle.plate_number  + ')' + '. Expected arrival time is ' + eta + '. For more updates use the MOOVE App.');
          end
        end   
        data = { employee_trip_id: trip_route.employee_trip.id, eta: eta }
        data = data.merge({data: data})
        data[:data].merge!(push_type: :driver_started_trip)
        data.merge!(notification: { title: I18n.t("push_notification.driver_started_trip.title"), body: I18n.t("push_notification.driver_started_trip.body", eta: eta) })
        PushNotificationWorker.perform_async(trip_route.employee_trip.employee.user_id, :driver_started_trip , data)
        # Send a silent push to all employees on trip start
        employee_trips.each do |employee_trip|
          if employee_trip.canceled? || employee_trip.missed? || employee_trip == trip_route.employee_trip
            #Do not send a notification in case of canceled or missed trip or to the first user to whom push is already sent
            next
          end
          PushNotificationWorker.perform_async(employee_trip.employee.user_id, :driver_started_trip_silent, { id: employee_trip.id, data: {id: employee_trip.id, push_type: :driver_started_trip_silent} }, :user)
        end
      end      
    else
      #Get the time taken to reach driver start location and office current location
      trip_route = self.trip_routes.order('scheduled_route_order ASC').first
      if trip_route.present?
        start_location = self.start_location
        end_location = [trip_route.scheduled_start_location[:lat], trip_route.scheduled_start_location[:lng]]
        route = GoogleService.new.directions(
            start_location,
            end_location,
            mode: 'driving',
            avoid: 'tolls',
            departure_time: Time.now.in_time_zone('Chennai')
        )
        route_data = route.first[:legs]
        eta = Time.now.in_time_zone('Chennai') + (route_data[0][:duration_in_traffic][:value]).ceil
        eta = eta.strftime("%H:%M")

        employee_trips.each do |employee_trip|
          # Do not send a notification in case the employee trip has been canceled
          if employee_trip.canceled? || employee_trip.missed?
            #Do not send a notification in case of canceled or missed trip
            next
          end

          notification_channel = Configurator.get_notifications_channel('send_notification_driver_start_trip')
          if notification_channel[:sms]
            # Send SMS to all employee for trip start
            @user = User.employee.where(id: employee_trip.employee.user_id).first
            if @user.present?
              @user_driver = User.driver.where(id: driver.user_id).first
              SMSWorker.perform_async(@user.phone, ENV['OPERATOR_NUMBER'], @user_driver.full_name + ' is on the way to your pick-up location in ' + vehicle.colour + ' ' + vehicle.make + ' ' + vehicle.model + '(' + vehicle.plate_number  + ')' + '. Expected arrival time is ' + eta + '. For more updates use the MOOVE App.');
            end
          end
          data = { employee_trip_id: employee_trip.id, eta: eta }
          data = data.merge({data: data})
          data[:data].merge!(push_type: :driver_started_trip)
          data.merge!(notification: { title: I18n.t("push_notification.driver_started_trip.title"), body: I18n.t("push_notification.driver_started_trip.body", eta: eta) })
          PushNotificationWorker.perform_async(employee_trip.employee.user_id, :driver_started_trip , data)
        end
      end
    end
  end

  def schedule_notify_employee_trip_started
    ScheduleNotifyEmployeeTripStartedWorker.perform_async(self.id)
  end

  def schedule_update_trip_distance_duration
    ScheduleUpdateTripDistanceDurationWorker.perform_async(self.id)
  end

  # Set scheduled trip duration after driver starts the trip
  def update_trip_distance_duration
    return if employee_trips.empty? # for factorygirl test passing @TODO: remove later
    #Send notification to only first employee in case of check in
    if self.check_in?
      #Get the first valid trip route
      trip_route = self.trip_routes.order('scheduled_route_order ASC').where.not(status: [:canceled, :missed ]).first
      #Get the time taken to reach driver start location and first valid user pick up location
      start_location = self.start_location
      end_location = [trip_route.scheduled_start_location[:lat], trip_route.scheduled_start_location[:lng]]
      route = GoogleService.new.directions(
          start_location,
          end_location,
          mode: 'driving',
          avoid: 'tolls',
          departure_time: Time.now.in_time_zone('Chennai')
      )
      route_data = route.first[:legs]
      initial_duration = (route_data[0][:duration_in_traffic][:value].to_f / 60).ceil
    else
      #Get the time taken to reach driver start location and office current location
      trip_route = self.trip_routes.order('scheduled_route_order ASC').first
      start_location = self.start_location
      end_location = [trip_route.scheduled_start_location[:lat], trip_route.scheduled_start_location[:lng]]
      route = GoogleService.new.directions(
          start_location,
          end_location,
          mode: 'driving',
          avoid: 'tolls',
          departure_time: Time.now.in_time_zone('Chennai')
      )
      route_data = route.first[:legs]
      initial_duration = (route_data[0][:duration_in_traffic][:value].to_f / 60).ceil
    end    

    if self.bus_rider?
      bus_trip_routes = trip_routes.to_a.uniq {|e| e.bus_stop_name}
      duration = bus_trip_routes.map(&:scheduled_duration).sum + wait_time_trip * bus_trip_routes.size
      distance = bus_trip_routes.map(&:scheduled_distance).sum          
    else
      duration = trip_routes.map(&:scheduled_duration).sum + wait_time_trip * trip_routes.size
      distance = trip_routes.map(&:scheduled_distance).sum          
    end

    trip_start_date = Time.now + initial_duration.minutes

    update_attributes!(scheduled_approximate_duration: duration, scheduled_approximate_distance: distance, scheduled_date: trip_start_date)
  end

  # Save start date of the trip sent from the mobile app
  def save_actual_start_trip_date(request_date)
    self.update!(start_date: Time.at(request_date.to_i))
  end

  # Save real date given by the mobile app
  def save_actual_trip_accept_date(request_date)
    self.update!(trip_accept_time: Time.at(request_date.to_i))
  end

  def get_driver_eta(drivers, end_lat, end_lng)
    return [] if drivers.blank?

    # if self.check_in?
    #   trip_route = self.trip_routes.order('scheduled_route_order ASC').where.not(status: [:canceled, :missed ]).first
    #   if trip_route.present?
    #     end_location = [trip_route.scheduled_start_location[:lat], trip_route.scheduled_start_location[:lng]]
    #   end
    # else
    #   end_location = self.site.location
    # end

    end_location = [end_lat, end_lng]
    start_location = []
    drivers.each_with_index do |driver, i|
      driver_location = driver.user.current_location

      if driver_location.present?
        start_location.push(driver_location)
      end
    end
  
    if start_location.blank? || end_location.blank?
      eta = []
      drivers.each_with_index do |driver|
        eta.push("--")
      end
      return eta 
    end
    
    begin
      # Multiple parameters distance matrix
      matrix = GoogleService.new.distance_matrix(start_location, end_location,
          mode: 'driving',
          language: 'en-AU',
          avoid: 'tolls',
          units: 'imperial',
          departure_time: Time.now.in_time_zone('Chennai'))
      
      eta = []
      i = 0
      drivers.each_with_index do |driver|
        driver_location = driver.user.current_location

        if driver_location.present?
          eta.push(matrix[:rows][i][:elements][0][:duration_in_traffic][:text])
          i = i + 1
        else
          eta.push("--")
        end
      end
    rescue
      eta = []
      drivers.each_with_index do |driver|
        eta.push("--")
      end      
    end

    eta
  end

  def unassign_driver_info
    update(driver: nil, vehicle: nil)
  end

  def delete_if_first_female
    employee_trips.each { |et| et.remoe_employee_trip } if is_first_female_pickup
  end

  def check_if_female_in_trip
    employee_trips.each do |employee_trip|
      if employee_trip.employee.gender == 'female'
        return true
      end
    end
    return false
  end

  def resequence_if_required
    default_ret = {
      female_exception: false,
      resequence_trip: false
    }

    return default_ret if self.bus_rider?
    @employee_trip_ids = []
    @trip_routes = self.trip_routes.where.not(status: :canceled).order('scheduled_route_order ASC')

    return default_ret if @trip_routes.blank?

    @trip_routes.each do |trip_route|
      @employee_trip_ids.push(trip_route.employee_trip.id)
    end

    resequence_trip = false
    female_exception = TripValidationService.is_female_exception(@employee_trip_ids, self.trip_type)

    if female_exception
      #Get all employee trip ids ordered by route order      

      ret = TripValidationService.resequence_employee_trips(@employee_trip_ids, self.trip_type)

      if ret[:sorted_employee_trip_ids].blank?
        return {
          female_exception: female_exception,
          resequence_trip: resequence_trip
        }        
      end

      @employee_trip_ids = ret[:sorted_employee_trip_ids]

      female_exception = false
      resequence_trip = true

      #update route order for employee trips
      @employee_trip_ids.each_with_index do |et, i|
        @et = EmployeeTrip.find(et)
        @et.update!(:route_order => i)
      end

      create_or_update_route
    end

    return {
      female_exception: female_exception,
      resequence_trip: resequence_trip
    }
  end

  def resequence_active_trip
    return if self.bus_rider?
    @employee_trip_ids = []
    @trip_routes = self.trip_routes.order('scheduled_route_order ASC')

    non_missed_trip_routes = @trip_routes.where.not(status: ['missed', 'canceled'])

    return if non_missed_trip_routes.blank?

    non_missed_employee_trips = []

    non_missed_trip_routes.each do |tr|
      non_missed_employee_trips.push(tr.employee_trip.id)
    end

    female_exception = TripValidationService.is_female_exception(non_missed_employee_trips, self.trip_type)

    if female_exception
      ret = TripValidationService.resequence_employee_trips(non_missed_employee_trips, self.trip_type)

      if ret[:sorted_employee_trip_ids].blank?
        #Female could not be resequenced
        ret = TripValidationService.remove_first_last_female_employee(non_missed_employee_trips, self.trip_type)

        # return in case the trip has been deleted
        return if !self || self.trip_routes.blank? || self.trip_routes.count == 0

        #Check if the trip needs to be completed after the deletion of female employee
        if trip_routes.first.present? && ret
          trip_routes.first.check_if_trip_completed
        end

        return if self.completed?

        if ret
          create_or_update_route
        end

        #Check for female exception in recursion
        resequence_active_trip 
        return
      end

      @employee_trip_ids = ret[:sorted_employee_trip_ids]

      et1 = EmployeeTrip.find(@employee_trip_ids[ret[:first_position]])
      et2 = EmployeeTrip.find(@employee_trip_ids[ret[:second_position]])

      route_order1 = et1.route_order
      route_order2 = et2.route_order
      et1.update!(route_order: route_order2)
      et2.update!(route_order: route_order1)

      create_or_update_route
    end
  end

  def service_type
    if self.bus_rider
      'BUS'
    else
      if TripValidationService.is_nodal(employee_trips.first.employee, employee_trips.first.date)
        'NODAL'
      else
        'D2D'
      end
    end
  end

  def handle_car_break_down
    if self.active?
      #Check if all employees are not picked up, unassign driver in that case
      if (trip_routes.where(:status => ['not_started']).size == trip_routes.size)
        #Do not remove employees from the trip and unassign the driver
        self.unassign_driver_due_to_car_broke_down!
        return
      end
      # Remove all the Employees from the trip with trip route status as not_started, driver_arrived
      self.trip_routes.each do |trip_route|
        if trip_route.not_started? || trip_route.driver_arrived?
          Notification.create!(:trip => self, :driver => self.driver, :employee => trip_route.employee_trip.employee,:employee_trip => trip_route.employee_trip, :message => 'car_break_down_employee_removed', :new_notification => true, :resolved_status => false, :reporter => 'Moove System').send_notifications
          # Send SMS to the employees
          @user = User.employee.where(id: trip_route.employee_trip.employee.user_id).first
          if @user.present?
            SMSWorker.perform_async(@user.phone, ENV['OPERATOR_NUMBER'], "Car assigned to pick you up has broken down. We will be assigning an alternate vehicle for you soon.")
          end
          trip_route.employee_trip.remoe_employee_trip
        end
      end
    else
      self.unassign_driver_due_to_car_broke_down!
    end
  end

  def resolve_panic_notification
    @notification = Notification.where(:trip => self, :resolved_status => false, :message => ['panic'])
    @notification.each do |notification|
      notification.update!(resolved_status: true)
    end    
  end

  def wait_time_trip
    if self.check_in?
      case self.service_type
        when 'D2D'
          Configurator.get('wait_time_at_pickup_D2D').to_i
        when 'BUS'
          Configurator.get('wait_time_at_pickup_BUS').to_i
        when 'NODAL'
          Configurator.get('wait_time_at_pickup_NODAL').to_i
      end
    else
      0
    end
  end

  def time_to_arrive
    buffer_time = 0
    if self.check_in?
      buffer_time = Configurator.get('report_time_check_in').to_i
    end

    buffer_time
  end

  def notify_if_female_in_trip
    if self.is_guard_required?
      @notification = Notification.where(trip: self, message: 'female_first_or_last_in_trip', resolved_status: false).first
      if @notification.blank?
        Notification.create!(trip: self, message: 'female_first_or_last_in_trip', resolved_status: false, new_notification: true, :reporter => "Moove System").send_notifications
      end
    end
  end
  
  protected  
  # Set first trip type as default
  def set_trip_type
    self.trip_type = employee_trips.first.trip_type unless self.trip_type.present?
  end

  # female filter
  def female_filter_results
    # calculate checkin time
    if self.check_in?
      time = employee_trips.minimum(:date).in_time_zone(Time.zone).strftime( '%H%M' ).to_i
    else
      time = employee_trips.maximum(:date).in_time_zone(Time.zone).strftime( '%H%M' ).to_i
    end

    if 600 > time || time > 1930
      waypoints = employee_trips.joins(:employee).order("employees.gender DESC, employees.distance_to_site DESC").to_a
    else
      waypoints = employee_trips.joins(:employee).order('employees.distance_to_site DESC').to_a
    end
    waypoints
  end

  # Check in 5 min if driver is still not assigned
  def enqueue_request_expiration_job
    # self.update(assign_request_expired_date: Time.new + DRIVER_ASSIGN_REQUEST_EXPIRATION)

    # AutoRejectManifestWorker.perform_at(self.assign_request_expired_date, self.id, self.driver_id)
    self.update(assign_request_expired_date: Time.new + DRIVER_ASSIGN_REQUEST_EXPIRATION)

    #Send Assign Request push two times more and update time
    AutoSendReAssignmentPush.perform_at(self.assign_request_expired_date, self.id, self.driver_id)
    AutoSendReAssignmentPush.perform_at(self.assign_request_expired_date + DRIVER_ASSIGN_REQUEST_EXPIRATION , self.id, self.driver_id)
    AutoRejectManifestWorker.perform_at(self.assign_request_expired_date + (DRIVER_ASSIGN_REQUEST_EXPIRATION * 2), self.id, self.driver_id)
  end

  def enqueue_request_restart_expiration_job
    self.update(assign_request_expired_date: Time.new + DRIVER_ASSIGN_REQUEST_EXPIRATION)
    AutoRejectManifestWorker.perform_at(self.assign_request_expired_date, self.id, self.driver_id)    
  end

  # Send push notification to driver about new assignment
  def renotify_driver_about_assignment
    @user = User.driver.where(id: driver.user_id).first
    if @user.present?
      SMSWorker.perform_async(@user.phone, ENV['OPERATOR_NUMBER'],
        'A new trip has been assigned. Please ACCEPT it using the MOOVE App within 3 minutes. This trip is for ' + (self.scheduled_approximate_distance / 1000).to_s + ' kms and will take about ' + self.scheduled_approximate_duration.to_s + ' minutes to complete.')
    end

    data = { 
        data: {
            trip_id: self.id,
            status: self.status,
            trip_type: self.trip_type,
            passengers: self.passengers,
            approximate_duration: self.scheduled_approximate_duration,
            approximate_distance: self.scheduled_approximate_distance,
            date: self.scheduled_date.to_i,
            assign_request_expired_date: self.assign_request_expired_date.to_i,
            push_type: :driver_new_trip_assignment
        }
    }

    PushNotificationWorker.perform_async(
        driver.user_id,
        :driver_new_trip_assignment,
        data
    )
  end

  # Send push notification to driver about new assignment
  def notify_driver_about_assignment
    @user = User.driver.where(id: driver.user_id).first
    if @user.present?
      SMSWorker.perform_async(@user.phone, ENV['OPERATOR_NUMBER'], 
        'A new trip has been assigned. Please ACCEPT it using the MOOVE App within 3 minutes. This trip is for ' + (self.scheduled_approximate_distance / 1000).to_s + ' kms and will take about ' + self.scheduled_approximate_duration.to_s + ' minutes to complete.')

      push_data = {
          trip_id: self.id,
          action: 'driver_new_trip_assignment'
      }

      #Send SMS for new trip request along with push
      # SMSWorker.perform_async(driver.offline_phone, ENV['OPERATOR_NUMBER'], 
      #   push_data.to_json)
    end

    data = {
        data: {
            trip_id: self.id,
            status: self.status,
            trip_type: self.trip_type,
            passengers: self.passengers,
            approximate_duration: self.scheduled_approximate_duration,
            approximate_distance: self.scheduled_approximate_distance,
            date: self.scheduled_date.to_i,
            assign_request_expired_date: self.assign_request_expired_date.to_i,
            push_type: :driver_new_trip_assignment
        }
    }

    PushNotificationWorker.perform_async(
        driver.user_id,
        :driver_new_trip_assignment,
        data
    )
  end

  # Send push notification to driver about unassignment
  def notify_driver_about_unassignment
    if driver.present?
      push_data = {
          trip_id: self.id,
          action: 'driver_new_trip_unassignment'
      }

      #Send SMS for new trip request along with push
      SMSWorker.perform_async(driver.offline_phone, ENV['OPERATOR_NUMBER'], 
        push_data.to_json)

      data = {driver_id: driver.user_id, data: {driver_id: driver.user_id, push_type: :driver_new_trip_unassignment} }
      PushNotificationWorker.perform_async(
          driver.user_id,
          :driver_new_trip_unassignment,
          data)
    end
  end

  #Send push notification to driver about unassignment due to security reasons
  def notify_driver_about_unassignment_due_to_security
    if driver.present?
      push_data = {
          trip_id: self.id,
          action: 'driver_new_trip_unassignment'
      }

      #Send SMS for new trip request along with push
      SMSWorker.perform_async(driver.offline_phone, ENV['OPERATOR_NUMBER'], 
        push_data.to_json)

      data = {driver_id: driver.user_id, data: {driver_id: driver.user_id, push_type: :driver_new_trip_unassignment} }
      PushNotificationWorker.perform_async(
          driver.user_id,
          :driver_new_trip_unassignment,
          data)
    end
  end  

  def add_notification_unassign_driver_due_to_female_exception
    Notification.create!(:trip => self, :driver => driver, :message => 'female_exception_driver_unassigned', :new_notification => true, :resolved_status => false, :reporter => 'Moove System').send_notifications
  end

  def add_notification_unassign_driver_due_to_car_broke_down
    Notification.create!(:trip => self, :driver => driver, :message => 'car_break_down_driver_unassigned', :new_notification => true, :resolved_status => false, :reporter => 'Moove System').send_notifications
  end

  def notify_driver_trip_cancel
    if driver.present?
      # Send SMS for Driver Trip Cancel
      push_data = {
          trip_id: self.id,
          action: 'driver_cancel_trip'
      }

      #Send SMS for new trip request along with push
      SMSWorker.perform_async(driver.offline_phone, ENV['OPERATOR_NUMBER'], 
        push_data.to_json)

      data = {driver_id: driver.user_id, data: {driver_id: driver.user_id, push_type: :driver_cancel_trip}}
      PushNotificationWorker.perform_async(
          driver.user_id,
          :driver_cancel_trip,
          data)
    end 
  end

  def auto_resolve_notifications
    @notifications = Notification.where(:trip => self).where(:resolved_status => false)
    @notifications.each do |notification|
      notification.update!(resolved_status: true)
    end
  end

  # Send push notification to employees about new trip
  def notify_employees_about_upcoming_trip
    notification_channel = Configurator.get_notifications_channel('send_notification_driver_assigned')
    employee_trips.each do |employee_trip|
      if notification_channel[:sms]
        @user = User.employee.where(id: employee_trip.employee.user_id).first
        if @user.present?
          @user_driver = User.driver.where(id: driver.user_id).first
          if self.check_in?
            SMSWorker.perform_async(@user.phone, ENV['OPERATOR_NUMBER'], "Driver #{driver&.full_name} (#{vehicle&.plate_number}) will be picking you up for the #{self.employee_trips&.first&.date&.in_time_zone('Chennai').strftime("%H:%M")} Check In to office. Driver Mobile Number - #{self.driver&.phone}. You can track your ride from the MOOVE Rider App.")
          else
            SMSWorker.perform_async(@user.phone, ENV['OPERATOR_NUMBER'], "Driver #{self.driver&.full_name} (#{self.vehicle&.plate_number}) will be picking you up for the #{self.employee_trips&.first&.date&.in_time_zone('Chennai').strftime("%H:%M")} Check Out from office. Driver Mobile Number - #{self.driver&.phone}. You can track your ride from the MOOVE Rider App.")
          end
        end
      end

      if employee_trip.canceled? || employee_trip.missed?
        #Do not send a notification in case of canceled or missed trip
        next
      end          
      data = {
          employee_trip_id: employee_trip.id,
          status: employee_trip.status,
          trip_type: employee_trip.trip_type,
          schedule_date: employee_trip.date.to_i,
          driver_arrive_date: employee_trip.approximate_driver_arrive_date.to_i,
      }
      data = data.merge({data: data})
      day = get_arrive_date_day(employee_trip.approximate_driver_arrive_date.in_time_zone('Chennai'))
      time = employee_trip.approximate_driver_arrive_date.in_time_zone('Chennai').strftime("%H:%M")
      data[:data].merge!(push_type: :employee_upcoming_trip)
      data.merge!(notification: { title: I18n.t("push_notification.employee_upcoming_trip.title"), body: I18n.t("push_notification.employee_upcoming_trip.body", day: day, time: time) })
      PushNotificationWorker.perform_async(employee_trip.employee.user_id, :employee_upcoming_trip , data)
    end
  end

  # Remove driver from expired trip
  def unassign_driver
    Notification.create!(:trip => self, :driver => driver, :message => 'not_accepted_manifest', :new_notification => true).send_notifications
    self.update(driver: nil, assign_request_expired_date: nil)
  end

  # create notification
  def create_notify_not_accepted_manifest
    Notification.create!(:trip => self, :driver => driver, :message => 'not_accepted_manifest', :resolved_status => false, :new_notification => true).send_notifications
  end

  # create notification
  def create_notify_completed
    reporter = "Driver: #{driver.full_name}"

    @existing_notification = Notification.where(:trip => self,:driver => driver, :message => 'trip_completed').first

    if @existing_notification.blank?
      Notification.create!(:trip => self, :driver => driver, :message => 'trip_completed', :new_notification => true, :resolved_status => true, :reporter => reporter).send_notifications
    end
  end

  # Save real date when driver accepted a trip
  def save_trip_accept_date
    if self.trip_accept_time.blank?
      self.update!(trip_accept_time: Time.now)
    end
  end

  # Save the date when trip is assigned to a driver
  def save_assign_trip_date
    self.update!(trip_assign_date: Time.now)
  end

  # Save real date when driver started a trip
  def save_start_trip_data
    if start_date.blank?
      self.update!(start_date: Time.now)
    end
  end

  # Save real trip duration and completed date
  def save_completed_trip_data
    now = Time.now

    # Fetch the time of last completed or missed trip    
    trip_route = TripRoute.unscoped.where(trip: self).where(status: :completed).order('scheduled_route_order DESC').limit(1).first
    if trip_route.present?
     now = trip_route.completed_date
    else
     trip_route = TripRoute.unscoped.where(trip: self).where(status: :missed).order('scheduled_route_order DESC').limit(1).first
     if trip_route.present?
       now = trip_route.missed_date
     end              
    end

    duration = ( (now - self.start_date) / 60 ).round

    self.update!(completed_date: now, real_duration: duration)
  end

  # Start employee trips
  def set_employee_trips_as_started
    employee_trips.each do |et|
      et.trip_stared!
    end
  end

  # Resolve all notifications when a trip gets canceled or completed
  def resolve_all_trip_notifications
    @notification = Notification.where(:trip => self, :resolved_status => false).where.not(:message => ['panic', 'female_exception_female_removed'])
    @notification.each do |notification|
      notification.update!(resolved_status: true)
    end
  end

  def resolve_trip_state_notifications
    @notification = Notification.where(:trip => self, :resolved_status => false, :message => ['driver_didnt_accept_trip', 'trip_should_start', 'trip_not_started', 'car_break_down_driver_unassigned'])
    @notification.each do |notification|
      notification.update!(resolved_status: true)
    end
  end
  
  def add_driver_accepted_trip_notification
    reporter = "Driver: #{driver.full_name}"

    Notification.create!(:trip => self, :driver => self.driver, :message => 'driver_accepted_trip', :resolved_status => true, :new_notification => true, :reporter => reporter).send_notifications
  end

  def add_driver_start_trip_notification
    reporter = "Driver: #{driver.full_name}"

    Notification.create!(:trip => self, :driver => self.driver, :message => 'driver_started_trip', :resolved_status => true, :new_notification => true, :reporter => reporter).send_notifications    
  end

  def add_operator_assigned_trip_notification
    reporter = "Operator: #{Current.user.full_name}"

    Notification.create!(:trip => self, :driver => self.driver, :message => 'operator_assigned_trip', :resolved_status => true, :new_notification => true, :reporter => reporter).send_notifications    
  end

  # Seve trip to employee trips
  def change_employee_trip_status
    employee_trips.each do |employee_trip|

      if employee_trip.canceled? || employee_trip.missed?
        #Do not send a notification in case of canceled or missed trip
        next
      end
      employee_trip.added_to_trip!
      PushNotificationWorker.perform_async(employee_trip.employee.user_id, :employer_planned_trip, { id: employee_trip.id, data: {id: employee_trip.id, push_type: :employer_planned_trip} }, :user)
    end unless ingested?
  end

  def notify_operator_created_trip
    #reporter = "Operator: #{Current.user.full_name}"
    if !Current.user.nil?
	    reporter = "Operator: #{Current.user.full_name}"
    else
 	    reporter = "Operator:"
    end

    Notification.create!(trip: self, message: 'operator_created_trip', resolved_status: true, new_notification: true, reporter: reporter).send_notifications    
  end

  def resolve_female_removed_notification
    @notification = Notification.where(:employee_trip => employee_trips, :resolved_status => false, :message => ['female_exception_female_removed', 'car_break_down_employee_removed'])
    @notification.each do |notification|
      notification.update!(resolved_status: true)
    end    
  end

  def check_if_valid_trip(employee_trips, trip_type)
    employee_trips = EmployeeTrip.where("employee_trips.id in (?)", employee_trips)
    waypoints = employee_trips.joins(:employee).order("employees.distance_to_site DESC")
    return "No Employees in Trip" if waypoints.empty?
    #Check for female filter
    female_filter_failed = false
    # TODO: Try to understart how it works - is_day_shift )
    if trip.is_guard_required?
      female_filter_failed = true
    end
    # if trip_type == "check_in" && waypoints.first.employee&.gender == "female" && !is_day_shift && ENV["ENALBE_GUARD_PROVISIONGING"] == "true"
    #   #Apply female filter
    #   female_filter_failed = true
    # elsif trip_type == "check_out" && waypoints.last.employee&.gender == "female" && !is_day_shift && ENV["ENALBE_GUARD_PROVISIONGING"] == "true"
    #   #Apply female filter
    #   female_filter_failed = true
    # end

    waypoints = waypoints.to_a.compact
    first_waypoint = waypoints.shift
    last_waypoint = waypoints.pop if trip_type == "check_out"

    origin = first_waypoint.site_location

    destination = first_waypoint.employee_address
    trip_start_date = employee_trips.maximum(:date).in_time_zone("Kolkata")
    if trip_type == "check_in"
      trip_start_date = trip_start_date - DEFAULT_DRIVER_CHECKIN_START_TIME
    else
      trip_start_date = trip_start_date + DEFAULT_DRIVER_CHECKOUT_START_TIME
    end
    trip_start_date = Time.now.in_time_zone("Kolkata") if trip_start_date < Time.now.in_time_zone("Kolkata")

    begin
      route = get_route(origin, destination, trip_start_date, waypoints.map{|et| et.employee_address})

      reordered_waypoints = route.first[:waypoint_order].map{|i| waypoints[i]}
      reordered_waypoints.push(first_waypoint)

      route_data = route.first[:legs]

      if trip_type == "check_in"
        reordered_waypoints = reordered_waypoints.reverse
        route_data = route_data.reverse
      end

      total_distance = 0
      total_duration = 0
      reordered_waypoints.each_with_index.map do |employee_trip, i|
        if trip_type == "check_in"
          start_location, end_location = [route_data[i][:end_location],route_data[i][:start_location]]
        else
          start_location, end_location = [route_data[i][:start_location],route_data[i][:end_location]]
        end

        new_route_data_intr = get_route(start_location, end_location, trip_start_date).first[:legs]
        total_distance += route_data[i][:distance][:value]
        total_duration += (new_route_data_intr[0][:duration_in_traffic][:value].to_f / 60).ceil
      end
    rescue
      return "Network error. Please try again."
    end

    if (total_distance / 1000) > MAXIMUM_TRIP_DISTANCE
      return "Roster exceeds Maximum Distance Exception"
    end

    if total_duration > MAXIMUM_TRIP_DURATION
      return "Roster exceed Maximum Duration Exception"
    end

    if female_filter_failed && employee_trips.size == MAX_EMPLOYEES_IN_A_TRIP
      return "Reduce roster size since guard will be added because of female exception"
    end

    return "passed" 
  end

  def haversine_distance( lat1, lon1, lat2, lon2 )
    dlon = lon2 - lon1
    dlat = lat2 - lat1

    dlon_rad = dlon * RAD_PER_DEG
    dlat_rad = dlat * RAD_PER_DEG

    lat1_rad = lat1 * RAD_PER_DEG
    lon1_rad = lon1 * RAD_PER_DEG

    lat2_rad = lat2 * RAD_PER_DEG
    lon2_rad = lon2 * RAD_PER_DEG

    a = (Math.sin(dlat_rad/2))**2 + Math.cos(lat1_rad) *
         Math.cos(lat2_rad) * (Math.sin(dlon_rad/2))**2
    c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))

    distance_in_meters = Rmeters * c
    distance_in_meters
  end

  private

  def get_arrive_date_day(arrive_date)
    return "Today" if arrive_date.to_date == Date.today
    return "Tomorrow" if arrive_date.to_date == Date.today + 1.day
    arrive_date.to_date
  end

  def trip_assigned_get_location
    # response = HTTParty.get(URI.escape("http://0.0.0.0/api/v3/trips/#{self.id}/start_trip_eta"))
    GetStartTripEtaWorker.perform_async(self.id)
  end
end
