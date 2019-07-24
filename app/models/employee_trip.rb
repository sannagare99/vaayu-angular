require 'services/trip_validation_service'

class EmployeeTrip < ApplicationRecord
  include AASM
  include TripScopes
  extend AdditionalFinders
  extend TimeUpdater

  DATATABLE_PREFIX = 'empltrip'
  # When rating is less or equal than this one, ask additional trip data
  RATING_TO_ASK_TRIP_DETAILS = 3

  belongs_to :site
  belongs_to :trip
  belongs_to :employee
  belongs_to :employee_cluster
  belongs_to :employee_schedule

  has_one :trip_route, dependent: :destroy
  has_many :trip_change_requests, dependent: :destroy
  has_many :employee_trip_issues, dependent: :destroy

  accepts_nested_attributes_for :employee_trip_issues

  # validates :employee, :allow_nil => true, :uniqueness => { :scope => :trip_id }

  # Rating can be 1-5 or nil
  validates :rating, allow_nil: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 5 }
  # Details can be filled only if rating is less than 3
  validates :employee_trip_issues, absence: { message: "cannot be specified when trip rating is above #{RATING_TO_ASK_TRIP_DETAILS}" }, if: Proc.new { |et| et.rating.nil? || et.rating > RATING_TO_ASK_TRIP_DETAILS  }

  validates :employee_id, uniqueness: { scope: [:trip_type, :date], message: "Trip already exist" }, on: :create

  enum trip_type: [:check_in, :check_out]
  enum state: [:scheudle, :ad_hoc]

  # Find by trip type
  scope :by_trip_type, -> (trip_type) { where(trip_type: trip_type)}
  scope :no_trip_created, -> { where(trip: nil)}
  scope :not_dismissed, -> { where(dismissed: false) }
  scope :not_completed, -> { where.not(status: [:completed, :canceled]) }
  scope :scheduled, -> { where.not(schedule_date: nil) }

  # validate :employee_trips_are_unique, on: :create

  attr_accessor :check_in, :check_out

  # An address where car should pick up him
  def employee_address
    employee.home_address
  end

  # employee full name
  def employee_full_name
    employee.full_name
  end

  def employee_bus_trip_id
    self.employee.bus_trip_route.bus_trip.id
  end

  # get trip nuumber for frontend
  def trip_number
    trip.blank? ? '' : trip.scheduled_date&.strftime("%m/%d/%Y") + ' - ' + trip.id.to_s
  end

  aasm :column => :status do
    state :upcoming, :initial => true

    state :ingested

    state :current
    state :missed
    state :completed

    state :trip_created
    # @TODO - refactoring: probably this state is not using anymore
    state :unassigned

    state :changed_approved

    state :active_trip
    state :ad_hoc

    state :approved
    state :reassigned

    state :canceled

    event :added_to_trip do
      transitions :to => :trip_created
    end
    event :unassign do
      transitions :from => [:trip_created, :current], :to => :upcoming, :after => :remove_from_trip
      end
    event :approved_unassign do
      transitions :from => [:upcoming, :trip_created, :active_trip], :to => :changed_approved, :after => :remove_from_trip
    end

    event :trip_stared do
      transitions :to => :current
    end

    event :employee_missed_trip do
      transitions to: :missed, after: :create_notify_about_missed
    end

    event :trip_completed, after_commit: [:send_trip_complete_sms] do
      transitions :from => [:trip_started, :active_trip, :current], to: :completed
      transitions :from => [:missed], to: :missed
      transitions :from => [:canceled], to: :canceled   
    end

    event :trip_canceled do
      transitions to: :canceled, :after => :cancel_trip
    end
  end

  def employee_trip_zone
    zone
  end
  
  def employee_trip_date
    date.strftime("%m/%d/%Y %H:%M") unless date.blank?
  end

  def employee_geohash_substring_six
    employee.geohash[0..5] unless employee.geohash.blank?
  end

  def employee_geohash_substring_five
    employee.geohash[0..4] unless employee.geohash.blank?
  end

  def employee_geohash_substring_four
    employee.geohash[0..3] unless employee.geohash.blank?
  end

  def employee_geohash_substring_three
    employee.geohash[0..2] unless employee.geohash.blank?
  end  

  def employee_trip_date_substring
    date.strftime('%Y-%m-%d')
  end

  def bus_trip_route_id
    bus_trip_route.id unless bus_trip_route.blank?
  end

  def site_location
    employee.site.location
  end

  # trip destination
  def destination
    case trip_type
      when 'check_in'
        employee_address
      when 'check_out'
        employee.site.address
    end
  end

  # @TODO: destination_lat and destination_lng should be one method to return array or hash
  # trip destination latitude
  def destination_lat
    case trip_type
      when 'check_in'
        employee.home_address_latitude
      when 'check_out'
        employee.site.latitude
    end
  end

  # trip destination longitude
  def destination_lng
    case trip_type
      when 'check_in'
        employee.home_address_longitude
      when 'check_out'
        employee.site.longitude
    end
  end

  # Check when driver will arrive to employee
  def approximate_driver_arrive_date
    trip_route.approximate_driver_arrive_date if trip_route.present?
  end

  # Check when driver will drop off an employee
  def approximate_drop_off_date
    trip_route.approximate_drop_off_date if trip_route.present?
  end

  # Display eta (pick up of drop off time depends on trip type)
  def eta
    trip_route.eta if trip_route.present?
  end

  # Display eta (pick up of drop off time depends on trip type)
  def planned_eta
    trip_route.planned_eta if trip_route.present?
  end  

  def actual_time
    if trip.check_in?
      if !planned_eta.nil? && !trip_route.driver_arrived_date.nil?
        time = ((trip_route.driver_arrived_date - planned_eta)/60).to_i
        if(time > 0)
          "+#{time}"
        else
          "#{time}"
        end
      else
        "--"
      end
    else
      if !planned_eta.nil? && !trip_route.completed_date.nil?
        time = ((trip_route.completed_date - planned_eta)/60).to_i
        if(time > 0)
          "+#{time}"
        else
          "#{time}"
        end
      else
        "--"
      end
    end
  end

  def onboard_time
    if trip.check_in?
      if !planned_eta.nil? && !trip_route.on_board_date.nil?
        time = ((trip_route.on_board_date - planned_eta)/60).to_i
        if(time > 0)
          "+#{time}"
        else
          "#{time}"
        end
      else
        "--"
      end    
    end
  end

  # Get latest trip change request
  def latest_trip_change_request
    self.trip_change_requests.order(created_at: :desc).first
  end

  # Is trip has been already rated
  def rated?
    ! self.rating.nil?
  end

  # Rate trip from 1 to 5
  # Optionally leave feedback and specify trip issues (not_timely, unsafe, dirty)
  def rate(rating, rating_feedback = nil, trip_issues = [])
    trip_issues ||= []

    if self.rated?
      errors.add(:base, 'The trip has already been rated')
      return false
    end

    unless trip_issues.blank?
      unless trip_issues.is_a? Array
        errors.add(:trip_issues, 'should be an array')
        return false
      end

      trip_issues = trip_issues.map do |issue|
        if EmployeeTripIssue.issues.keys.include? issue
          EmployeeTripIssue.new(issue: issue)
        else
          errors.add(:base, "#{issue} is not a valid key for trip_issues")
          return false
        end
      end
    end

    self.update(rating: rating, rating_feedback: rating_feedback, employee_trip_issues: trip_issues)
  end

  def create_notify_about_missed
    # @notification = Notification.where(:trip => trip, :employee => employee, :message => 'employee_no_show', :resolved_status => false).first
    # if @notification.blank?
    #   Notification.create!(:trip => trip, :driver => trip.driver, :employee => employee,  :message => 'employee_no_show', :resolved_status => true, :new_notification => false).send_notifications
    # end
  end

  def check_in_formatted
    self.check_in.in_time_zone(Time.zone).strftime('%H:%M') if self.check_in
  end

  # HH:MM check out output for forms
  def check_out_formatted
    self.check_out.in_time_zone(Time.zone).strftime('%H:%M') if self.check_out
  end

  def self.fetch_checkin_and_checkout(check_in_attr, check_out_attr, zone=Time.zone)
    check_in_date = zone.parse("#{check_in_attr[:schedule_date]} #{check_in_attr[:check_in]}")
    check_out_date = zone.parse("#{check_out_attr[:schedule_date]} #{check_out_attr[:check_out]}")
    check_out_date += 1.day unless check_in_date < check_out_date
    [check_in_date, check_out_date]
  end

  def self.fetch_date(check_in_attr, check_out_attr, zone = Time.zone)
    if check_in_attr.present?
      check_in_date = zone.parse("#{check_in_attr[:schedule_date]} #{check_in_attr[:check_in]}")
      [check_in_date]
    elsif check_out_attr.present?
      check_out_date = zone.parse("#{check_out_attr[:schedule_date]} #{check_out_attr[:check_out]}")
      shift = Shift.find_by('end_time = ?', check_out_attr[:check_out])
      if shift.present?
        check_in_time, check_out_time =
          zone.parse("#{Time.now.to_date} #{shift.start_time}"),
          zone.parse("#{Time.now.to_date} #{shift.end_time}")
        check_out_date = check_out_date + 1.day if check_in_time >= check_out_time
      end
      [check_out_date]
    end
  end

  def self.check_in_check_out_is_invalid(check_in_attr, check_out_attr)
    begin
      check_in_date = Time.zone.parse("#{check_in_attr[:schedule_date]} #{check_in_attr[:check_in]}")
      check_out_date = Time.zone.parse("#{check_out_attr[:schedule_date]} #{check_out_attr[:check_out]}")
      return false
    rescue ArgumentError => re
      return true
    end
  end

  def self.check_if_date_is_valid(check_in_attr, check_out_attr)
    begin
      if check_in_attr.present?
        check_in_date = Time.zone.parse("#{check_in_attr[:schedule_date]} #{check_in_attr[:check_in]}")
      end

      if check_out_attr.present?
        check_out_date = Time.zone.parse("#{check_out_attr[:schedule_date]} #{check_out_attr[:check_out]}")
      end
      return true
    rescue ArgumentError => re
      return false
    end    
  end

  def self.create_or_update(employee, attributes)
    attributes[:check_in_attributes].values.sort_by { |x| x["schedule_date"] }.each_with_index do |check_in_attr, i|
      attribute = attributes[:check_out_attributes].values.sort_by { |x| x["schedule_date"] }[i]
      if attribute.nil?
        attribute = {}
      end
      check_out_attr = attribute.merge({"employee_id" => employee.id, "bus_rider" => employee.bus_travel})
      check_in_attr = check_in_attr.merge({"employee_id" => employee.id, "bus_rider" => employee.bus_travel})

      # next if check_in_check_out_is_invalid(check_in_attr, check_out_attr)

      # next if (check_in_attr[:id].blank? && check_in_attr[:check_in].blank?) || (check_out_attr[:id].blank? && check_out_attr[:check_out].blank?)
      
      # Do scheduling operation if both check in id and check in date are not blank
      if check_in_attr[:id].present? || check_in_attr[:check_in].present?
        if check_in_attr[:id].present?
          if check_in_attr[:check_in].blank?
            EmployeeTrip.upcoming.where(id: check_in_attr[:id]).no_trip_created.destroy_all if check_in_attr[:check_in].blank?
          else
            if check_in_attr[:site_id].present? && check_if_date_is_valid(check_in_attr, nil)
              dates = fetch_date(check_in_attr, nil)
              update_employee_trip([check_in_attr], dates, 'check_in')
            end
          end
        else
          if check_in_attr[:site_id].present? && check_if_date_is_valid(check_in_attr, nil)
            dates = fetch_date(check_in_attr, nil)
            create_employee_trip([check_in_attr], dates, 'check_in')
          end
        end
      end

      if check_out_attr[:id].present? || check_out_attr[:check_out].present?
        if check_out_attr[:id].present?
          if check_out_attr[:check_out].blank?
            EmployeeTrip.upcoming.where(id: check_out_attr[:id]).no_trip_created.destroy_all if check_out_attr[:check_out].blank?
          else
            if check_out_attr[:site_id].present? && check_if_date_is_valid(nil, check_out_attr)
              dates = fetch_date(nil, check_out_attr)
              update_employee_trip([check_out_attr], dates, 'check_out')
            end
          end
        else
          if check_out_attr[:site_id].present? && check_if_date_is_valid(nil, check_out_attr)
            dates = fetch_date(nil, check_out_attr)
            create_employee_trip([check_out_attr], dates, 'check_out')
          end
        end
      end
    end
    #   if check_in_attr[:id].present?
    #     if check_in_attr[:check_in].blank? || check_out_attr[:check_out].blank?
    #       EmployeeTrip.upcoming.where(id: check_in_attr[:id]).no_trip_created.destroy_all if check_in_attr[:check_in].blank?
    #       EmployeeTrip.upcoming.where(id: check_out_attr[:id]).no_trip_created.destroy_all if check_out_attr[:check_out].blank?
    #     else
    #       dates = fetch_checkin_and_checkout(check_in_attr, check_out_attr)
    #       update_employee_trip([check_in_attr, check_out_attr], dates)
    #     end
    #   else
    #     dates = fetch_checkin_and_checkout(check_in_attr, check_out_attr)
    #     create_employee_trip([check_in_attr, check_out_attr], dates)
    #   end
    # end
  end

  def self.create_employee_trip(attributes, dates, trip_type="")
    attrs = []
    attributes.first.merge({site_id: attributes.last[:site_id]}) if attributes.last[:id].present?
    attributes.select { |et| et[:id].blank? }.each_with_index { |et_attr, i| attrs << et_attr.slice("site_id", "employee_id", "bus_rider").merge({date: dates[i], trip_type: trip_type.blank? ? i : trip_type, state: 0, schedule_date: Time.zone.parse("#{et_attr['schedule_date']} 10:00:00")}) if et_attr.present? }
    EmployeeTrip.create(attrs)
    update_employee_trip([{}, attributes.last], [{}, dates.last]) if attributes.last[:id].present?
  end

  def self.update_employee_trip(attributes, dates, trip_type="")
    attributes.each_with_index do |et_attr, i|
      next if et_attr.blank?
      if et_attr["id"].present?
        et = EmployeeTrip.where(id: et_attr["id"], status: ['upcoming', 'unassigned', 'reassigned']).first
        et.update_attributes(et_attr.slice("site_id", "bus_rider").merge({date: dates[i], trip_type: trip_type.blank? ? i : trip_type, schedule_date: Time.zone.parse("#{et_attr['schedule_date']} 10:00:00")})) if et.present?
      else
        create_employee_trip([{}, et_attr], ["", dates[i]])
      end
    end
  end

  def self.trips_by_range(employee, range_from, range_to)
    range_from = Date.parse(range_from)
    range_to = Date.parse(range_to) + 1.day
    Date.beginning_of_week = :sunday
    trips = employee.employee_trips.where(schedule_date: range_from..range_to).group_by do |et|
      dat = et.schedule_date
      Date.new(dat.strftime("%Y").to_i, dat.strftime("%m").to_i, dat.strftime("%d").to_i).end_of_week.cweek
    end

    trips.map { |week_no, et| { week_no => et.as_json(only: [:id, :date, :trip_type, :schedule_date, :site_id, :shift_id, :status])} }
  end

  # @TODO - refactoring: do not pass self into the method, probably move to before destroy
  def destroy_guard_trip(et)
    et.trip_route.remove_from_trip if et.trip_route.present?
    et.destroy
  end

  # Check if need to delete guards trip
  def first_or_last_female_delete
    # if trip not created – the guard is not either
    return unless trip_route.present?
    guard = trip.employees.guard
    # if guard is not in trip - nothing to do here
    return unless guard.present?
    tr = trip.trip_routes.to_a

    # if there is only employee and his guard
    # or
    # the next employee is male for check in trip
    # or
    # the previous employee is male for check out trip
    # trip.needs_guard?
    # if tr.count == 2 || ((check_in? && tr[trip_route.scheduled_route_order + 1]&.employee&.male?) || (check_out? && tr[trip_route.scheduled_route_order - 1]&.employee&.male?))
    #   # is one guard per trip ????
    #   # trip.guard.destroy
    #   destroy_guard_trip(trip.employee_trips.where(employee_id: guard.first.id).first)
    # end

    return if tr.count == 2
    return destroy_guard_trip(trip.employee_trips.where(employee_id: guard.first.id).first) if tr.count == 2 || ((check_in? && tr[trip_route.scheduled_route_order + 1]&.employee&.male?) || (check_out? && tr[trip_route.scheduled_route_order - 1]&.employee&.male?))
  end

  # @TODO - refactoring: fix typo in method's name
  # Destroy guard's trip if employee is a guard
  #
  # remove_from_trip at the end
  def remoe_employee_trip(current_user = nil)
    reporter = "Operator: #{Current.user.full_name}"    
        
    if employee.is_guard?
      if !Current.user.employee? && !Current.user.driver?
        Notification.create!(:trip => trip, :driver => trip.driver, :employee => employee, :message => 'guard_deleted_from_trip', :new_notification => true, :resolved_status => true, :reporter => reporter).send_notifications
      end
      destroy_guard_trip(self)
    else
      if !Current.user.employee? && !Current.user.driver?
        Notification.create!(:trip => trip, :driver => trip.driver, :employee => employee, :message => 'employee_deleted_from_trip', :new_notification => true, :resolved_status => true, :reporter => reporter).send_notifications
      end
      first_or_last_female_delete if employee.female?
      self.unassign!
    end
  end

  def set_zone
    self.update!(:zone => self.employee.zone.name, :is_clustered => true)
  end

  def get_related_trip(updated_time)
    zone = ActiveSupport::TimeZone.new("Chennai")

    trip_types = ["check_in", "check_out"].reject { |x| x == trip_type }
    trip = employee.employee_trips.where(trip_type: trip_types.first, schedule_date: schedule_date.beginning_of_day..schedule_date.end_of_day).first

    if trip.present?
      if self.check_in?
        check_in_attr = {schedule_date: schedule_date.to_date, check_in: updated_time}
        check_out_attr = {schedule_date: schedule_date.to_date, check_out: trip.date.in_time_zone(zone).strftime('%H:%M')}
      else
        check_in_attr = {schedule_date: schedule_date.to_date, check_in: trip.date.in_time_zone(zone).strftime('%H:%M')}
        check_out_attr = {schedule_date: schedule_date.to_date, check_out: updated_time}
      end
      dates = EmployeeTrip.fetch_checkin_and_checkout(check_in_attr, check_out_attr)
      self.check_in? ? dates.first : dates.last
    else
      zone.parse("#{schedule_date.to_date} #{updated_time}")
    end
  end

  def send_trip_complete_sms
    notification_channel = Configurator.get_notifications_channel('send_notification_employee_check_out')
    if notification_channel[:sms]
      if self.status == 'completed'
        @user = User.employee.where(id: self.employee.user_id).first
        if @user.present?
          SMSWorker.perform_async(@user.phone, ENV['OPERATOR_NUMBER'], 'Your trip has been completed. Please use the MOOVE App to rate this trip, and optionally provide additional feedback.');
        end        
      end
    end    
  end

  def pick_up_address(nodal = nil)
    if employee.is_guard
      employee.home_address
    else
      if employee.bus_travel?
        employee.bus_trip_route.stop_name
      else
        is_nodal_trip = false

        if nodal.present?
          if nodal[:is_nodal]
            is_nodal_trip = TripValidationService.check_if_nodal_trip(employee, date, nodal[:start_time], nodal[:end_time])
          end
        else
          is_nodal_trip = TripValidationService.is_nodal(employee, date)
        end

        if is_nodal_trip
          employee.nodal_address
        else
          employee.home_address
        end
      end
    end
  end

  def area(nodal = nil)
    if employee.is_guard
      employee.home_address
    else
      if employee.bus_travel?
        employee.bus_trip_route.stop_name
      else
        is_nodal_trip = false

        if nodal.present?
          if nodal[:is_nodal]
            is_nodal_trip = TripValidationService.check_if_nodal_trip(employee, date, nodal[:start_time], nodal[:end_time])
          end
        else
          is_nodal_trip = TripValidationService.is_nodal(employee, date)
        end

        if is_nodal_trip
          employee.nodal_name
        else
          employee.landmark.nil? || employee.landmark.blank? ? "--" : employee.landmark
        end
      end
    end    
  end

  def pick_up_lat_lng(nodal = nil)
    if employee.is_guard
      lat, lng = employee.home_address_latitude, employee.home_address_longitude
    else
      if employee.bus_travel?
        lat, lng = employee.bus_trip_route.stop_latitude, employee.bus_trip_route.stop_longitude
      else
        is_nodal_trip = false

        if nodal.present?
          if nodal[:is_nodal]
            is_nodal_trip = TripValidationService.check_if_nodal_trip(employee, date, nodal[:start_time], nodal[:end_time])
          end
        else
          is_nodal_trip = TripValidationService.is_nodal(employee, date)
        end

        if is_nodal_trip
          lat, lng = employee.nodal_address_latitude, employee.nodal_address_longitude
        else
          lat, lng = employee.home_address_latitude, employee.home_address_longitude
        end      
      end
    end
    {lat: lat, lng: lng}
  end

  def home_address
    if TripValidationService.is_nodal(employee, date)
      employee.nodal_address_location
    else
      employee.home_address_location
    end
  end
  private

  def remove_from_trip
    self.trip_route.remove_from_trip if self.trip_route.present?
    self.update!(:trip => nil)
  end

  def cancel_trip
    if self.trip_route.present?
      self.trip_route.cancel!
    end
  end

end
