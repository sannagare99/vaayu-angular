class TripRoute < ApplicationRecord
  include AASM
  belongs_to :employee_trip
  belongs_to :trip
  has_many :trip_route_exceptions, dependent: :destroy

  delegate :employee, to: :employee_trip
  delegate :driver, to: :trip, allow_nil: true
  delegate :vehicle, to: :trip, allow_nil: true
  delegate :site, to: :trip, allow_nil: true

  serialize :planned_start_location, Hash
  serialize :planned_end_location, Hash
  serialize :scheduled_start_location, Hash
  serialize :scheduled_end_location, Hash

  #Driver pick up and drop locations
  serialize :driver_arrived_location, Hash
  serialize :check_in_location, Hash
  serialize :drop_off_location, Hash
  serialize :missed_location, Hash

  after_create :send_sms_to_guard

  # Statuses when trip route is completed
  FINAL_STATUSES = [:completed, :canceled, :missed, :not_on_board_completed]

  # Statuses when all the employees have either onboarded or missed/cancelled the trip
  EMPLOYEE_ONBOARD_STATUSES = [:canceled, :on_board, :missed, :driver_arrived]

  # Status when the trip has been canceled
  CANCEL_STATUS = [:canceled]  

  #Geo fence distances
  CHECK_IN_I_AM_HERE = 500
  CHECK_OUT_I_AM_HERE = 500

  CHECK_IN_NO_SHOW = 500
  CHECK_OUT_NO_SHOW = 500

  CHECK_IN_CHECK_IN = 500
  CHECK_OUT_CHECK_IN = 500

  CHECK_IN_DROP_OFF = 500
  CHECK_OUT_DROP_OFF = 500

  MAX_DISTANCE_AWAY_IN_KM = 100.0
  RAD_PER_DEG             = 0.017453293

  Rkm     = 6371           # radius in kilometers, some algorithms use 6367
  Rmeters = Rkm * 1000     # radius in meters

  aasm column: :status, whiny_transitions: false do
    state :not_started, initial: true

    state :canceled
    state :driver_arrived
    state :on_board
    state :missed
    state :completed
    state :not_on_board
    state :not_on_board_completed

    event :cancel, after_commit: [ :update_trip_route_start_end, :check_if_trip_canceled, :notify_employee_trip_changed, :notify_driver_canceled ] do
      transitions to: :canceled
    end

    event :driver_arrived, before: :set_driver_arrived_date, after_commit: [ :notify_employee_driver_arrived, :notify_employee_trip_changed ] do
      transitions from: :not_started, to: :driver_arrived
    end

    event :missed, after_commit: [ :check_if_trip_completed, :set_employee_trip_missed, :notify_employee_missed_trip, :notify_employee_trip_changed, :set_missed_date ] do
      transitions from: :driver_arrived, to: :missed
    end

    event :boarded, before: :set_on_board_date, after_commit: [ :notify_employee_on_board, :notify_employee_trip_changed, :notify_driver_onboard ] do
      transitions from: [:not_on_board, :driver_arrived], to: :on_board
    end

    event :completed, after_commit: [:complete_check_out_trip, :check_if_trip_completed , :notify_employee_trip_completed, :notify_employee_trip_changed ], before: :set_completed_date do
      transitions from: [:on_board, :completed], to: :completed
    end

    event :not_on_board_completed, after_commit: [:complete_check_out_trip, :check_if_trip_completed , :notify_employee_trip_completed, :notify_employee_trip_changed ], before: :set_completed_date do
      transitions from: [:not_on_board], to: :not_on_board_completed
    end    

    event :not_on_board, after_commit: [:notify_employee_trip_changed, :check_if_trip_completed, :notify_employee_trip_changed] do
      transitions from: :driver_arrived, to: :not_on_board
    end

    event :not_on_board_missed, after_commit: [:set_employee_trip_missed, :notify_employee_missed_trip, :notify_employee_trip_changed, :set_missed_date] do
      transitions from: :not_on_board, to: :missed
    end
  end

  scope :ordered, -> { order(:scheduled_route_order) }
  scope :has_unresolved_suspending_exceptions, -> { joins(:trip_route_exceptions).merge(TripRouteException.unresolved_suspending) }


  def self.default_scope
    order(scheduled_route_order: :asc)
  end

  # Check when driver will arrive to employee
  def approximate_driver_arrive_date
    if trip.check_in?
      earlier_passengers = trip.trip_routes.where("scheduled_route_order < #{self.scheduled_route_order}").to_a.uniq {|e| e.scheduled_route_order}
      trip.scheduled_date + (earlier_passengers.pluck(:scheduled_duration).sum + trip.wait_time_trip * earlier_passengers.size).minutes
    else
      trip.scheduled_date
    end
  end

  # Check when driver will drop off an employee
  def approximate_drop_off_date
    if trip.check_in?
      trip.approximate_trip_end_date
    else
      earlier_passengers = trip.trip_routes.where("scheduled_route_order <= #{self.scheduled_route_order}").to_a.uniq {|e| e.scheduled_route_order}
      trip.scheduled_date + (earlier_passengers.pluck(:scheduled_duration).sum + trip.wait_time_trip * (earlier_passengers.size - 1)).minutes
    end
  end

  # Check when driver will arrive to employee according to the planned date
  def planned_driver_arrive_date
    if trip.check_in?
      earlier_passengers = trip.trip_routes.where("scheduled_route_order < #{self.scheduled_route_order}").to_a.uniq {|e| e.scheduled_route_order}      
      trip.planned_date + (earlier_passengers.pluck(:scheduled_duration).sum + trip.wait_time_trip * earlier_passengers.size).minutes
    else
      trip.planned_date
    end
  end

  # Check when driver will drop off an employee according to the planned date
  def planned_drop_off_date
    if trip.check_in?
      trip.planned_trip_end_date
    else
      earlier_passengers = trip.trip_routes.where("scheduled_route_order <= #{self.scheduled_route_order}").to_a.uniq {|e| e.scheduled_route_order}
      trip.planned_date + (earlier_passengers.pluck(:scheduled_duration).sum + trip.wait_time_trip * (earlier_passengers.size - 1)).minutes
    end
  end  

  # Display eta (pick up of drop off time depends on trip type)
  def eta
    trip.check_in? ? approximate_driver_arrive_date : approximate_drop_off_date
  end

  # Display planned eta (pick up of drop off time depends on trip type)
  def planned_eta
    trip.check_in? ? planned_driver_arrive_date : planned_drop_off_date
  end  

  def aasm_event_failed(event_name, old_state)
    self.errors.add(:base, :aasm, message: "Bad transition from #{old_state} to #{event_name}")
  end

  # get details about employee by trip_rout
  def get_employee_info
    {
        :id  => employee_trip.employee.id,
        :name => employee_trip.employee.full_name,
        :status => status,
        :eta => self.planned_driver_arrive_date&.strftime("%m/%d/%Y %H:%M").to_s,
        :actual_time => driver_arrived_date&.strftime("%m/%d/%Y %H:%M").to_s,
        :route_order => self.scheduled_route_order,
        :type => self.trip.trip_type,
        :cancel_exception => self.cancel_exception
    }.merge(employee_trip.employee.pick_up_lat_lng)
  end

  def check_trip_status
    self.status
  end

  def check_trip_type
    trip.trip_type
  end

  def check_trip_end_date
    trip.approximate_trip_end_date
  end

  # Check if the driver has picked up all the employees or they cancelled/missed the trip
  def check_if_all_employees_picked_up
    if (trip.trip_routes.where(status: EMPLOYEE_ONBOARD_STATUSES).size == trip.trip_routes.size) && ! trip.canceled?
      return true
    end
    false
  end

  def send_location_update(duration, all_employees_picked, trip_routes)
    i = -1
    # Send location update to all users
    trip_routes.each do |trip_route|
      duration_left = 0
      if all_employees_picked == true
        if trip_route.status === "driver_arrived"
          data = {
              duration: 0
          }
        else
          data = {
              duration: duration[0]
          }
        end  
      elsif trip_route.status === "not_started"
        if trip_route.check_trip_type === "check_in"
          i = i + 1
          val = 0
          duration.each do |dur|
            if val <= i
              duration_left = duration_left + dur
            else
              break
            end
            val = val + 1
          end
        else
          duration.each do |dur|
            duration_left = duration_left + dur
          end          
        end
        data = {
            duration: duration_left
        }        
      elsif trip_route.status === "on_board"
        if trip_route.check_trip_type === "check_in"   
          duration.each do |dur|
            duration_left = duration_left + dur
          end
        else
          i = i + 1
          val = 0
          duration.each do |dur|
            if val <= i
              duration_left = duration_left + dur
            else
              break
            end
            val = val + 1
          end
        end

        data = {
            duration: duration_left
        }
      else
        next
      end
      data = data.merge({data: data})
      data[:data].merge!(push_type: :driver_location_update)
      PushNotificationWorker.perform_async(trip_route.employee.user_id, :driver_location_update , data)
    end

    data = { duration: duration[0], data: {duration: duration[0], push_type: :driver_location_update} }
    #send the push to driver as well
    PushNotificationWorker.perform_async(driver.user_id, :driver_location_update , data)
  end

  def initiate_call(call_type)
    @user_driver = User.driver.where(id: driver.user_id).first
    @user_employee = User.employee.where(id: employee.user_id).first
    if call_type == '0'
      #Employee to Driver
      make_call(:To => @user_driver.phone, :From => @user_employee.phone, :CallerId => ENV['EXOTEL_CALLER_ID'], :CallType => 'trans')
      reporter = "Employee: #{employee.full_name}"
      Notification.create!(:trip => trip, :driver => driver, :employee => employee, :message => 'employee_called_driver', :resolved_status => true,:new_notification => true, :reporter => reporter).send_notifications
    else
      #Driver to Employee 
      make_call(:To => @user_employee.phone, :From => @user_driver.phone, :CallerId => ENV['EXOTEL_CALLER_ID'], :CallType => 'trans')
      reporter = "Driver: #{driver.full_name}"
      Notification.create!(:trip => trip, :driver => driver, :employee => employee, :message => 'driver_called_employee', :resolved_status => true,:new_notification => true, :reporter => reporter).send_notifications      
    end
  end

  def call_operator
    @user_driver = User.driver.where(id: driver.user_id).first
    @user_operator = User.operator.order('last_active_time DESC').first
    if @user_driver.present? && @user_operator.present?
      make_call(:From => @user_operator.phone, :To => @user_driver.phone, :CallerId => ENV['EXOTEL_CALLER_ID'], :CallType => 'trans')
    end
  end

  def remove_from_trip
    if trip.trip_routes.size == 1
      trip.destroy
    else
      self.destroy

      if !trip.is_guard_required?
        trip.resolve_female_first_or_last_notification
      else
        trip.notify_if_female_in_trip
      end
    end
  end

  def check_driver_arrived_geofence(lat, lng)
    #Start location is the driver location
    start_location = {:lat => lat.to_f, :lng => lng.to_f}
    if trip.trip_type === "check_in"
      distance = CHECK_IN_I_AM_HERE
      end_location = self.scheduled_start_location
      employee = self.employee_trip.employee
    else
      distance = CHECK_OUT_I_AM_HERE
      end_location = self.trip.site_location_hash
    end
    check_geofence('driver_arrived' ,start_location, end_location, distance, employee)
  end

  def check_on_board_geofence(lat, lng)
    start_location = {:lat => lat.to_f, :lng => lng.to_f}
    if trip.trip_type === "check_in"
      distance = CHECK_IN_CHECK_IN
      end_location = self.scheduled_start_location
      employee = self.employee_trip.employee
    else
      employee = self.employee_trip.employee
      distance = CHECK_OUT_CHECK_IN
      end_location = self.trip.site_location_hash
    end
    check_geofence('check_in' ,start_location, end_location, distance, employee)    
  end

  def check_completed_geofence(lat, lng)
    start_location = {:lat => lat.to_f, :lng => lng.to_f}
    if trip.trip_type === "check_in"
      distance = CHECK_IN_DROP_OFF
      end_location = self.trip.site_location_hash
    else
      distance = CHECK_OUT_DROP_OFF
      end_location = self.scheduled_start_location
      employee = self.employee_trip.employee
    end
    check_geofence('drop_off' ,start_location, end_location, distance, employee)
  end

  def check_no_show_geofence(lat, lng)
    start_location = {:lat => lat.to_f, :lng => lng.to_f}
    if trip.trip_type === "check_in"
      distance = CHECK_IN_NO_SHOW
      end_location = self.scheduled_start_location
      employee = self.employee_trip.employee
    else
      distance = CHECK_OUT_NO_SHOW
      end_location = self.trip.site_location_hash
    end
    check_geofence('missed' ,start_location, end_location, distance, employee)
  end
  
  def complete_with_exception
    unless ['canceled', 'missed', 'completed'].include?(self.status)
      self.update!(cancel_exception: true)
    end    
  end

  def update_trip_route_start_end
    # Check if the start and end location of trip route are in proper order
    trip_routes = trip.trip_routes.order('scheduled_route_order ASC')

    previous_valid_trip = nil
    next_valid_trip = nil

    array_position = 0
    while array_position < trip_routes.size do
     if trip_routes[array_position] == self.scheduled_route_order
       break
     else
       array_position = array_position + 1
     end
    end 

    j = array_position
    while (j - 1 >= 0) do
      if trip_routes[j - 1].status != "missed" && trip_routes[j - 1].status != "canceled"
        previous_valid_trip = trip_routes[j - 1]
        break
      end
      j = j - 1
    end

    j = array_position
    while (j + 1 < trip_routes.size) do
      if trip_routes[j + 1].status != "missed" && trip_routes[j - 1].status != "canceled"
        next_valid_trip = trip_routes[j + 1]
        break
      end
      j = j + 1
    end

    if previous_valid_trip != nil
      if next_valid_trip != nil
        if trip.trip_type === "check_in"
          previous_valid_trip.update!(scheduled_end_location: next_valid_trip.scheduled_start_location)
        else
          next_valid_trip.update!(scheduled_start_location: previous_valid_trip.scheduled_end_location)
        end
      else
        if trip.trip_type === "check_in"
          previous_valid_trip.update!(scheduled_end_location: trip_routes[trip_routes.size - 1].scheduled_end_location)
        end
      end

      if next_valid_trip != nil && trip.trip_type === "check_out"
        next_valid_trip.update!(scheduled_start_location: self.scheduled_start_location)
      end
    end    
  end

  def send_sms_to_guard
    return unless employee.is_guard?
    SMSWorker.perform_async(employee.phone, ENV['OPERATOR_NUMBER'], "Dear #{employee.f_name}. You have been assigned to a #{trip.trip_type.humanize} trip for the #{trip.employee_trips.first.date.in_time_zone('Chennai').strftime("%H:%M")} shift. Remember to board the vehicle #{trip.vehicle&.plate_number}. Your Driver is #{trip.driver&.full_name} (#{trip.driver&.phone})")
  end

  def set_actual_driver_arrived_date(request_date)
    self.driver_arrived_date = Time.at(request_date.to_i)
  end

  # Save time when driver onboarded employee
  def set_actual_on_board_date(request_date)
    self.on_board_date = Time.at(request_date.to_i)
  end

  # Save when driver completed trip route
  def set_actual_completed_date(request_date)
    self.completed_date = Time.at(request_date.to_i)
  end

  # Save when driver completed trip route
  def set_actual_missed_date(request_date)
    self.missed_date = Time.at(request_date.to_i)
  end

  def employee_log_planned_eta
    if trip.check_in?
      trip.planned_date + trip.trip_routes.map(&:planned_duration).sum
    else
      trip.scheduled_date
    end
  end

  def onboard_missed_date
    if self.missed?
      missed_date
    else
      on_board_date
    end
  end

  # Mark trip as completed when last employee trip completed
  def check_if_trip_completed
    if (trip.trip_routes.where(status: FINAL_STATUSES).size == trip.trip_routes.size) && ! trip.canceled?
      trip.trip_routes.each do |tr|
        if tr.not_on_board?
          tr.not_on_board_missed!
        else
          if !tr.employee_trip.missed? && !tr.employee_trip.canceled? && !tr.employee_trip.completed?
            tr.employee_trip.trip_completed!
          end
        end
      end
      trip.completed!
      #trip.employee_trips.each do |et|
      #  if !et.missed? || !et.canceled?
      #    et.trip_completed!
      #  end
      #end
    end

  end

  def pick_up_stop_address
    if employee_trip.employee.is_guard
      employee_trip&.employee&.home_address
    else
      case self.trip.service_type
        when 'D2D'
          employee_trip&.employee&.home_address
        when 'BUS'
          employee_trip&.employee&.bus_trip_route&.stop_address
        when 'NODAL'
          employee_trip&.employee&.nodal_address
      end
    end
  end

  def pick_up_stop_name
    if employee_trip.employee.is_guard
      "#{employee_trip.employee.f_name} #{employee_trip.employee.l_name}"
    else    
      case self.trip.service_type
        when 'D2D'
          "#{employee_trip.employee.f_name} #{employee_trip.employee.l_name}"
        when 'BUS'
          employee_trip&.employee&.bus_trip_route&.stop_name
        when 'NODAL'
          employee_trip&.employee&.nodal_name
      end
    end
  end

  def pick_up_stop_lat
    if employee_trip.employee.is_guard
      employee_trip&.employee&.home_address_latitude
    else    
      case self.trip.service_type
        when 'D2D'
          employee_trip&.employee&.home_address_latitude
        when 'BUS'
          employee_trip&.employee&.bus_trip_route&.stop_latitude
        when 'NODAL'
          employee_trip&.employee&.nodal_address_latitude
      end
    end
  end

  def pick_up_stop_lng
    if employee_trip.employee.is_guard
      employee_trip&.employee&.home_address_longitude
    else
      case self.trip.service_type
        when 'D2D'
          employee_trip&.employee&.home_address_longitude
        when 'BUS'
          employee_trip&.employee&.bus_trip_route&.stop_longitude 
        when 'NODAL'
          employee_trip&.employee&.nodal_address_longitude
      end
    end
  end

  def set_move_to_next_step_date(request_date)
    self.move_to_next_step_date = Time.at(request_date.to_i)
  end

  protected
  def check_geofence(type ,start_location, end_location, min_distance, employee)
    # route_intr = GoogleService.new.directions(
    #     start_location,
    #     end_location,
    #     mode: 'driving'
    # )
    # route_data = route_intr.first[:legs]
    # distance = route_data[0][:distance][:value]
    distance = haversine_distance(start_location[:lat], start_location[:lng], end_location[:lat], end_location[:lng])    

    # Get minimum distance from the configurator
    driver_narrow_geofence_distance = Configurator.where('request_type' => 'driver_narrow_geofence_distance').first

    if driver_narrow_geofence_distance.present?
      min_distance = driver_narrow_geofence_distance.value.to_f
    end

    reporter = "Driver: #{trip.driver.full_name}"

    if distance > min_distance
      if employee.nil?
        @existing_notification = Notification.where(:trip => self.trip,:driver => self.driver, :message => "out_of_geofence_#{type}_site").first
      else
        @existing_notification = Notification.where(:trip => self.trip,:driver => self.driver, :employee => employee, :message => "out_of_geofence_#{type}").first
      end
      if @existing_notification.blank?
        if employee.nil?
          @prev_notification = Notification.where(:trip => self.trip, :driver => self.driver, :message => "out_of_geofence_#{type}_site", :resolved_status => false).first

          if @prev_notification.blank?
            @notification = Notification.create!(:trip => self.trip, :driver => self.driver, :message => "out_of_geofence_#{type}_site", :new_notification => true, :resolved_status => false, :reporter => reporter)
          end
        else

          @prev_notification = Notification.where(:trip => self.trip, :driver => self.driver, :employee => employee, :message => "out_of_geofence_#{type}", :resolved_status => false).first

          if @prev_notification.blank?
            @notification = Notification.create!(:trip => self.trip, :driver => self.driver, :employee => employee, :message => "out_of_geofence_#{type}", :new_notification => true, :resolved_status => false, :reporter => reporter)
          end
        end
        @notification.send_notifications
        ResolveNotification.perform_at(Time.now + 5.minutes, @notification.id)
      end
    else
      message = ''
      employee_for_notification = nil
      #Generate Notification for Events
      case type
        when 'driver_arrived'
          if trip.check_in?          
            message = 'driver_arrived_check_in'
            employee_for_notification = employee
          else
            message = 'driver_arrived_check_out'
          end            
        when 'check_in'
          if trip.check_in?
            message = 'employee_on_board_check_in'
            employee_for_notification = employee
          else
            message = 'employee_on_board_check_out'
            employee_for_notification = employee
          end
        when 'drop_off'
          if trip.check_in?
            message = 'employee_drop_off_check_in'
          else
            employee_for_notification = employee
            message = 'employee_drop_off_check_out'
          end
      end
      #Generate Notification
      if employee_for_notification.blank?
        @existing_notification = Notification.where(:trip => self.trip, :driver => self.driver, :message => message).first
      else
        @existing_notification = Notification.where(:trip => self.trip, :driver => self.driver,:employee => employee_for_notification, :message => message).first
      end
      if @existing_notification.blank?
        @notification = Notification.create!(:trip => self.trip, :driver => self.driver, :employee => employee_for_notification, :message => message, :new_notification => true, :resolved_status => true, :reporter => reporter)
        @notification.send_notifications
      end
    end
  end

  def check_if_need_destroy
    # Do not destroy a cancelled trip
    # unless ['active', 'completed'].include?(self.trip.status)
    #   self.destroy
    # end
  end

  #Mark trip as canceled
  def check_if_trip_canceled

    if (trip.trip_routes.where(status: CANCEL_STATUS).size == trip.trip_routes.size)
      trip.cancel!
    end

  end

  def complete_check_out_trip
    if trip.check_out?
      employee_trip.trip_completed!  
    end
  end

  # Save time when driver arrived to employee
  def set_driver_arrived_date
    if self.driver_arrived_date.blank?
      self.driver_arrived_date = Time.now
    end
  end

  # Save time when driver onboarded employee
  def set_on_board_date
    if self.on_board_date.blank?
      self.on_board_date = Time.now
    end
  end

  # Save when driver completed trip route
  def set_completed_date
    if self.completed_date.blank?
      self.completed_date = Time.now
    end
  end
  
  # Save when driver completed trip route
  def set_missed_date
    if self.missed_date.blank?
      self.missed_date = Time.now
    end
  end  

  def set_employee_trip_missed
    update_trip_route_start_end
    self.employee_trip.employee_missed_trip!
  end

  # Send push notification to employee when driver arrived
  def notify_employee_driver_arrived
    if employee_trip.canceled? || employee_trip.missed?
      #Do not send a notification in case of canceled or missed trip
      return
    end

    #Check the driver arrived time and scheduled arrival time.
    if approximate_driver_arrive_date - Time.now > 15.minutes
      driver_early = true
    end
    # Send SMS to employee when driver arrived
    current_time = Time.now.in_time_zone('Chennai').strftime("%H:%M")
    scheduled_time = approximate_driver_arrive_date.in_time_zone('Chennai').strftime("%H:%M")

    @user = User.employee.where(id: employee_trip.employee.user_id).first
    @user_driver = User.driver.where(id: driver.user_id).first
    
    notification_channel = Configurator.get_notifications_channel('send_notification_driver_arrived')

    if notification_channel[:sms]
      if @user.present?
        # if driver_early
        #   SMSWorker.perform_async(@user.phone, ENV['OPERATOR_NUMBER'], @user_driver.full_name + ' has arrived early at your pick-up location in ' + vehicle.colour + ' ' + vehicle.make + ' ' + vehicle.model + ' (' + vehicle.plate_number + '). You may board now or at your scheduled time of ' + scheduled_time + '.')
        # else
        #   SMSWorker.perform_async(@user.phone, ENV['OPERATOR_NUMBER'], @user_driver.full_name + ' has arrived at your pick-up location in ' + vehicle.colour + ' ' + vehicle.make + ' ' + vehicle.model + ' (' + vehicle.plate_number + ') at ' + current_time + '.')
        # end      
        SMSWorker.perform_async(@user.phone, ENV['OPERATOR_NUMBER'], 'Driver has arrived at your pick-up location in ' + vehicle.colour + ' ' + vehicle.make + ' ' + vehicle.model + ' (' + vehicle.plate_number + ').')
      end
    end

    data = { 
      employee_trip_id: employee_trip.id, 
      current_time: current_time, 
      driver_name: @user_driver.full_name,
      vehicle_color: vehicle.colour,
      vehicle_make: vehicle.make,
      vehicle_model: vehicle.model,
      vehicle_plate_number: vehicle.plate_number,
      driver_early: driver_early
    }
    data = data.merge({data: data})
    data[:data].merge!(push_type: :driver_arrived)
    if driver_early
      data.merge!(notification: { title: I18n.t("push_notification.driver_arrived_early.title"), body: I18n.t("push_notification.driver_arrived_early.body", driver_name: @user_driver.full_name, color: vehicle.colour, model: vehicle.model, make: vehicle.make, plate_no: vehicle.plate_number, scheduled_time: scheduled_time) })
    else
      data.merge!(notification: { title: I18n.t("push_notification.driver_arrived.title"), body: I18n.t("push_notification.driver_arrived.body", driver_name: @user_driver.full_name, color: vehicle.colour, model: vehicle.model, make: vehicle.make, plate_no: vehicle.plate_number, scheduled_time: scheduled_time) })
    end
    PushNotificationWorker.perform_async(employee.user_id, :driver_arrived, data)
  end

  # Send push notification to employee when driver marked he's on board
  def notify_employee_on_board
    data = { employee_trip_id: employee_trip.id, data: { employee_trip_id: employee_trip.id, push_type: :employee_on_board }, notification: I18n.t("push_notification.employee_on_board") }
    PushNotificationWorker.perform_async(employee.user_id, :employee_on_board, data)
    #Send push notification to next employee to be picked up with updated ETA
    if trip.check_in?
      #Send push notification to next valid employee
      trip_route = trip.trip_routes.order('scheduled_route_order ASC').where("scheduled_route_order > #{self.scheduled_route_order}").where.not(status: [:canceled, :missed ]).first
      if trip_route.present?
        updated_eta = (Time.now.in_time_zone('Chennai')+ (trip_route.scheduled_duration * 60)).strftime("%H:%M")
        data = { employee_trip_id: trip_route.employee_trip.id, updated_eta: updated_eta, data: {employee_trip_id: trip_route.employee_trip.id, updated_eta: updated_eta, push_type: :next_pick_up}}
        data.merge!(notification: { title: I18n.t("push_notification.next_pick_up.title"), body: I18n.t("push_notification.next_pick_up.body", updated_eta: updated_eta) })
        PushNotificationWorker.perform_async(trip_route.employee_trip.employee.user_id, :next_pick_up, data)
      end
    end
  end

  def notify_driver_canceled
    if driver
      data = {
          data: {
              driver_id: driver.user_id,
              push_type: :employee_canceled_trip
          }
      }
      PushNotificationWorker.perform_async(driver.user_id, :employee_canceled_trip, data)
    end
  end

  def notify_driver_onboard
    if driver
      data = {
          data: {
              driver_id: driver.user_id,
              push_type: :employee_checked_in
          }
      }
      PushNotificationWorker.perform_async(driver.user_id, :employee_checked_in, data)
    end
  end

  # Send push notification to employee when driver marked he's missed trip
  def notify_employee_missed_trip
    data = { employee_trip_id: employee_trip.id, data: {employee_trip_id: employee_trip.id, push_type: :employee_missed_trip}, notification: I18n.t("push_notification.employee_missed_trip") }
    PushNotificationWorker.perform_async(employee.user_id, :employee_missed_trip, data)
  end

  # Send push notification to employee when driver marked he's dropped off an employee
  def notify_employee_trip_completed
    data = {
        employee_trip_id: employee_trip.id
    }

    if driver
      data[:driver] = {
          user_id: driver.user_id,
          username: driver.username,
          email: driver.email,
          f_name: driver.f_name,
          m_name: driver.m_name,
          l_name: driver.l_name,
          phone: driver.phone,
          profile_picture: driver.full_avatar_url,
          operating_organization: {
              name: driver.operating_organization_name,
              phone: driver.operating_organization_phone
          }
      }
    end

    if vehicle
      data[:vehicle] = {
          id: vehicle.id,
          plate_number: vehicle.plate_number,
          make: vehicle.make,
          model: vehicle.model,
          colour: vehicle.colour,
          seats: vehicle.seats,
          make_year: vehicle.make_year,
          photo: vehicle.photo.url
      }
    end
    data = data.merge({data: data})
    data[:data].merge!(push_type: :employee_trip_completed)
    data.merge!(notification: I18n.t("push_notification.employee_trip_completed"))
    PushNotificationWorker.perform_async(employee.user_id, :employee_trip_completed , data)
    #Send push notification to next employee to be dropped with updated ETA
    if trip.check_out?      
      trip_route = trip.trip_routes.order('scheduled_route_order ASC').where("scheduled_route_order > #{self.scheduled_route_order}").where.not(status: [:canceled, :missed ]).first
      if trip_route.present?
        updated_eta = (Time.now.in_time_zone('Chennai')+ (trip_route.scheduled_duration * 60)).strftime("%H:%M")
        data = { employee_trip_id: trip_route.employee_trip.id, updated_eta: updated_eta, data: { push_type: :next_drop, employee_trip_id: trip_route.employee_trip.id, updated_eta: updated_eta } }
        data.merge!(notification: { title: I18n.t("push_notification.next_drop.title"), body: I18n.t("push_notification.next_drop.body", updated_eta: updated_eta) })
        PushNotificationWorker.perform_async(trip_route.employee_trip.employee.user_id, :next_drop, data)
      end
    end    
  end

  def notify_employee_trip_changed
    trip.try(:notify_employee_trips_changed)
  end

  def make_call(params)
    HTTParty.post(URI.escape("https://#{ENV['EXOTEL_SID']}:#{ENV['EXOTEL_TOKEN']}@twilix.exotel.in/v1/Accounts/#{ENV['EXOTEL_SID']}/Calls/connect"),
    {
      :query => params,
      :body => params
    })
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

end
