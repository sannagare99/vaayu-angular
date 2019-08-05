class Notification < ApplicationRecord
  include AASM
  DATATABLE_PREFIX = 'notification'

  belongs_to :driver
  belongs_to :employee
  belongs_to :trip
  belongs_to :employee_trip
  belongs_to :driver_request

  scope :operator_assigned_trip, -> { where(message: "operator_assigned_trip") }

  before_save :set_sequence
  before_save :set_receiver

  enum receiver: [:operator, :employer, :both]
  enum status: [:created, :archived]

  aasm :column => :status do
    state :created, :initial => true
    state :archived

    event :archive do
      transitions from: :created, :to => :archived
    end
  end

  def group_by_trip_id
    trip_id
  end

  # set params to Notification message
  def driver_name
    driver.nil? ? '' : driver.f_name + ' ' + driver.m_name.to_s + ' ' + driver.l_name
  end

  def driver_licence
    driver&.licence_number
  end

  def driver_phone
    driver&.phone
  end

  def driver_plate
    trip.nil? || trip.vehicle.nil? ? '' : trip.vehicle.plate_number
  end

  def employee_name
    employee.nil? ? '' : employee.f_name + ' ' + employee.m_name.to_s + ' ' + employee.l_name
  end

  def employee_id
    employee.nil? ? '' : employee.id
  end  

  def employee_company_id
    employee.nil? ? '' : employee.employee_id
  end

  def employee_phone
    employee.nil? ? '' : employee.phone
  end

  def trip_number
    if trip.nil?
      ''
    else
      trip.start_date.nil? ? trip.scheduled_date.strftime("%d/%m/%Y").to_s + ' - ' + trip.id.to_s : trip.start_date.strftime("%d/%m/%Y").to_s + ' - ' + trip.id.to_s
    end
  end

  def trip_url
    if trip.nil?
      ''
    else
      'trips/' + trip.id.to_s
    end
  end

  def get_remarks
    self.remarks.nil? ? '' : self.remarks
  end

  def send_notifications
    case message
      when 'panic','employee_no_show','not_on_board','still_on_board'
        WebNotificationWorker.perform_in( 2.seconds, self.id)
    end
  end

  # trip notifications sequence depend on message type
  def set_sequence
    case message
      when 'panic','employee_no_show','driver_no_show','car_break_down','car_broken_down','car_ok_pending','car_broke_down_trip','not_on_board','still_on_board','driver_didnt_accept_trip','trip_should_start','vehicle_ok','female_first_or_last_in_trip', 'employee_changed_trip','trip_not_started', 'female_exception_driver_unassigned','female_exception_female_removed', 'car_break_down_driver_unassigned', 'car_break_down_employee_removed', 'driver_over_speeding'
        self.sequence = 3
      when 'on_leave', 'on_leave_trip','out_of_geofence_check_in','out_of_geofence_drop_off','out_of_geofence_driver_arrived','out_of_geofence_missed','out_of_geofence_check_in_site','out_of_geofence_drop_off_site','out_of_geofence_driver_arrived_site','out_of_geofence_missed_site', 'female_exception_route_resequenced', 'employee_no_show_approved', 'book_ola_uber','driver_over_speeding'
        self.sequence = 2
      when 'driver_started_trip','trip_completed','driver_accepted_trip','operator_assigned_trip','complete_with_exception', 'operator_created_trip', 'driver_arrived_login', 'driver_on_board_login', 'driver_dropped_employee_logout', 'reassigned_trip', 'employee_canceled_trip', 'employee_canceled_trip_auto_approved', 'cancel_request_approved', 'employee_changed_trip_auto_approved', 'change_request_approved', 'call_employee', 'call_driver','guard_added', 'car_break_down_approved', 'car_break_down_declined','book_ola_uber', 'driver_arrived_check_in', 'driver_arrived_check_out', 'employee_on_board_check_in', 'employee_on_board_check_out', 'employee_drop_off_check_in', 'employee_drop_off_check_out', 'completed_with_exception', 'driver_called_employee', 'employee_called_driver', 'site_arrival_delay', 'first_pickup_delayed', 'employee_deleted_from_trip', 'guard_deleted_from_trip', 'driver_face_detection'
        self.sequence = 1
      else
        self.sequence = 0
    end
    return true
  end

  def set_receiver
    case message
      when 'employee_changed_trip', 'employee_changed_trip_auto_approved'
        # Notification to be received by only Employer
        self.receiver = 1
      # #Uncomment when we need to add Operator Notifications
      # when 'on_leave'
      #   # Notification to be received by only Operator
      #   self.receiver = 0
      else
        # Set receiver by default
        self.receiver = 2
    end
      
  end

  def get_info
    {
       :date => self.created_at.strftime("%m/%d/%Y"),
       :id => self.id,
       :created_at => self.created_at.strftime("%d/%m/%Y  %I:%M%p"),
       :display_message => I18n.t('notification.message.' + self.message, 
        employee_name: self.employee_name, 
        site_name: self&.trip&.site&.name, 
        driver_name: self.driver_name,
        notification_remarks: self&.get_remarks,
        employee_id: self.employee_company_id),
       :message => self.message,
       :trip_number => self.trip_number,
       :trip_url => self.trip_url,
       :trip_id => self.trip_id,
       :driver_id => self.driver_id,
       :driver_request_id => self.driver_request_id,

       :driver_name => self.driver_name,
       :driver_phone => self.driver_phone,
       :driver_licence => self.driver_licence,
       :driver_plate => self.driver_plate,

       :employee_name => self.employee_name,
       :employee_phone => self.employee_phone,
       :move_driver_to_next_step => "",
       :resolved_status => self.resolved_status,
       :reporter => self.reporter.blank? ? '' : self.reporter
       #:trip => trip_data(self.trip)
    }    
  end

  def trip_data(trip)
    {
       "DT_RowId" => "#{Trip::DATATABLE_PREFIX}-#{trip.id}",
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
       :is_guard_required => is_guard_required(trip),
    }
  end

  def is_guard_required(trip)
    begin
      trip.is_guard_required?
    rescue
      false
    end
  end

  def is_first_female_pickup(trip)
    begin
      trip.check_in? && @trip.trip_routes.order("scheduled_route_order").first.employee&.gender == "female"
    rescue
      false
    end
  end

  def is_last_female_drop(trip)
    begin
      trip.check_out? && @trip.trip_routes.order("scheduled_route_order").last.employee&.gender == "female"
    rescue
      false
    end
  end

  def emloyee_status(trip)
    employee_trips = EmployeeTrip.joins(:trip_route).where(:trip => trip).order('trip_routes.scheduled_route_order ASC')
    employee_trips.map do |employee_trip|
      employee_trip.trip_route&.get_employee_info
    end
  end   
end
