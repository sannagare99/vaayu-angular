class DriverRequest < ApplicationRecord
  include AASM

  belongs_to :driver
  belongs_to :vehicle

  enum request_type: [ :leave, :car_broke_down]
  enum reason: [ :sick, :emergency, :others ]
  enum trip_type: [ :check_in, :check_out ]

  after_create :notify_operator, :vehicle_broke_down_pending
  after_save :set_driver_sort_status

  aasm column: :request_state do
    state :pending, initial: true

    state :approved
    state :declined

    state :cancel
    state :cancel_approved
    state :cancel_declined

    event :cancel, after_commit: [:notify_operator, :vehicle_ok_now_pending, :notify_employees] do
      transitions to: :cancel
    end

    event :cancel_declined, after_commit: [:notify_operator, :notify_driver, :vehicle_broke_down, :notify_employees] do
      transitions to: :approved
    end

    event :cancel_approved, after_commit: [:notify_operator, :notify_driver, :vehicle_ok, :notify_employees] do
      transitions to: :cancel_approved
    end

    event :approve, after_commit: [:notify_operator, :approve_request, :notify_driver, :vehicle_broke_down, :notify_employees] do
      transitions from: :pending, to: :approved
    end

    event :decline, after_commit: [:notify_operator, :notify_driver, :vehicle_ok, :notify_employees] do
      transitions from: :pending, to: :declined
    end
  end

  DATATABLE_PREFIX = 'driver_reque'

  def driver_name
    driver.nil? ? '' : driver.f_name + ' ' + driver.m_name.to_s + ' ' + driver.l_name
  end

  def driver_phone
    driver&.phone
  end

  def notify_driver_about_change_in_status
    data = {driver_id: driver.user_id , data: {driver_id: driver.user_id, push_type: :driver_off_duty} }
    PushNotificationWorker.perform_async(
        driver.user_id,
        :driver_off_duty,
        data)
  end

  def set_driver_sort_status
    status = -1
    if driver.status == 'on_leave'
      status = 0  
    end

    notification = driver.compliance_notifications.active.order(updated_at: :desc).first
    # This notification to be shown below any car broke down or leave notification
    if notification.present?
      notification.checklist? ? status = 1 : status = 2
    end

    driver_request = DriverRequest.where(:driver => driver).where('start_date > ?', Time.now).where(:request_state => [:cancel, :pending]).first
    if driver_request.present?
      status = 3
    end

    driver.update_column('sort_status', status)
  end
  
  protected

  def vehicle_ok
    if request_type == 'car_broke_down'
      vehicle.vehicle_ok!
    end
  end

  def vehicle_broke_down
    if request_type == 'car_broke_down'
      vehicle.vehicle_broke_down!
    end
  end

  def vehicle_ok_now_pending
    if request_type == 'car_broke_down'
      vehicle.vehicle_ok_pending!
    end
  end

  def vehicle_broke_down_pending
    if request_type == 'car_broke_down'
      vehicle.vehicle_broke_down_pending!
    end
  end

  def approve_request
    case request_type.to_sym
      when :leave
        #Add a push worker to send this driver on leave at leave start time
        SendDriverOnLeave.perform_at(self.start_date, self.id, self.driver.id, 'on_leave')
        SendDriverOnLeave.perform_at(self.end_date, self.id, self.driver.id, 'off_duty')
      when :car_broke_down
      	#TODO :Implement this logic
    end
  end

  def notify_driver
    data = {
        driver_request_id: self.id,
        request_state: self.request_state,
        request_type: self.request_type,
        start_date: self.start_date.to_i,
        end_date: self.end_date.to_i,
        reason: self.reason,
    }

    data = data.merge({data: data})
    data[:data].merge!(push_type: :driver_request_answer)
    PushNotificationWorker.perform_async( driver.user_id, :driver_request_answer, data )

    case request_type.to_sym
      when :leave
        #Add a push worker to send this driver on leave at leave start time
        if self.approved?
          action = "leave_request_approved"
          message = "Your leave request from #{start_date.strftime('%m/%d/%Y %H:%M')} to #{end_date.strftime('%m/%d/%Y %H:%M')} has been approved by the operator."
        elsif self.declined?
          action = "leave_request_declined"
          message = "Your leave request from #{start_date.strftime('%m/%d/%Y %H:%M')} to #{end_date.strftime('%m/%d/%Y %H:%M')} has been declined by the operator."
        elsif self.cancel_declined?
          action = "leave_cancel_request_declined"
          message = "Your leave cancel request from #{start_date.strftime('%m/%d/%Y %H:%M')} to #{end_date.strftime('%m/%d/%Y %H:%M')} has been declined by the operator."      
        elsif self.cancel_approved?
          #Send driver off duty
          action = "leave_cancel_request_approved"
          driver.go_off_duty!
          message = "Your leave cancel request from #{start_date.strftime('%m/%d/%Y %H:%M')} to #{end_date.strftime('%m/%d/%Y %H:%M')} has been approved by the operator."
        end
      when :car_broke_down
        if self.approved?
          action = "car_broke_down_approved"
          message = "Your car broke down request has been approved by the operator."
        elsif self.declined?
          action = "car_broke_down_declined"
          message = "Your car broke down request has been declined by the operator."
        elsif self.cancel_declined?
          action = "vehicle_ok_now_declined"
          message = "Your vehicle ok now request has been declined by the operator."
        elsif self.cancel_approved?
          action = "vehicle_ok_now_approved"
          message = "Your vehicle ok now request has been approved by the operator."
        end
    end


    #Send SMS to the driver
    @user = User.employee.where(id: driver.user_id).first
    if @user.present?
      push_data = {
          trip_id: self.id,
          action: action
      }
      # Send SMS for offline actions
      # SMSWorker.perform_async(driver.offline_phone, ENV['OPERATOR_NUMBER'], 
      #   push_data.to_json)

      SMSWorker.perform_async(@user.phone, ENV['OPERATOR_NUMBER'], message);
    end
  end

  def notify_operator
    if request_type == 'car_broke_down'
      @trips = Trip.where(:vehicle => vehicle).where(:status => ['active', 'assigned', 'assign_requested', 'assign_request_expired'])
      @trips.each do |trip|
        if self.pending?
          reporter = "Driver: #{driver.full_name}"
          @notification = Notification.where(:driver_request => self, :driver => driver, :trip => trip, :message => 'car_break_down', :resolved_status => false).first

          if @notification.blank?
            Notification.create!(:driver_request => self, :driver => driver, :trip => trip, :message => 'car_break_down', :new_notification => true, :resolved_status => false, :reporter => reporter).send_notifications
          end
        elsif self.declined?
          # Resolve all notifications for this driver having car brokw down as status
        #   @notifications = Notification.where(:driver => driver).where(:trip => trip).where(:resolved_status => false).where(:message => 'car_broke_down')
        #   @notifications.each do |notification|
        #     notification.update!(resolved_status: true)
        #   end
        # elsif self.approved?
          # Notification.create!(:driver => driver, :trip => trip, :message => 'car_broken_down', :receiver => :operator, :new_notification => true, :resolved_status => false).send_notifications
          reporter = "Operator: #{Current.user.full_name}"
          Notification.create!(:driver => driver, :trip => trip, :message => 'car_break_down_declined', :new_notification => true, :resolved_status => true, :reporter => reporter).send_notifications
          resolve_car_broke_down_notification(driver, trip)
        elsif self.cancel?
          # Notification.create!(:driver => driver, :trip => trip, :message => 'car_ok_pending', :receiver => :operator, :new_notification => true, :resolved_status => false).send_notifications
        elsif self.cancel_declined?
          # @notifications = Notification.where(:driver => driver).where(:trip => trip).where(:resolved_status => false).where(:message => ['car_ok_pending'])
          # @notifications.each do |notification|
          #   notification.update!(resolved_status: true)
          # end
        elsif self.cancel_approved?
          # @notifications = Notification.where(:driver => driver).where(:trip => trip).where(:resolved_status => false).where(:message => ['car_broke_down', 'car_broken_down', 'car_ok_pending'])
          # @notifications.each do |notification|
          #   notification.update!(resolved_status: true)
          # end
        elsif self.approved?
          reporter = "Operator: #{Current.user.full_name}"
          Notification.create!(:driver => driver, :trip => trip, :message => 'car_break_down_approved', :new_notification => true, :resolved_status => true, :reporter => reporter).send_notifications
          resolve_car_broke_down_notification(driver, trip)
          trip.handle_car_break_down
        end        
      end
    end
    # case request_type.to_sym
    #   when :leave
    #     if self.pending?
    #       Notification.create!(:driver => driver, :message => 'on_leave', :receiver => :operator, :resolved_status => true,:new_notification => false, :status => :archived).send_notifications
    #     elsif self.cancel?
    #       Notification.create!(:driver => driver, :message => 'cancel_leave', :receiver => :operator, :resolved_status => true,:new_notification => false, :status => :archived).send_notifications
    #     end
    #   when :car_broke_down
    #     if self.pending?
    #       Notification.create!(:driver => driver, :message => 'car_broke_down', :receiver => :operator, :resolved_status => false,:new_notification => true).send_notifications
    #     elsif self.cancel?
    #       Notification.create!(:driver => driver, :message => 'vehicle_ok', :receiver => :operator, :resolved_status => false,:new_notification => true).send_notifications
    #     end
    # end
  end

  def notify_employees
    #Inform employees when driver signals car broke down or car ok
    if vehicle.present? && request_type == "car_broke_down"    
      @trips = Trip.where(:vehicle => vehicle).where(:status => ['active', 'assigned', 'assign_requested', 'assign_request_expired'])
      @trips.each do |trip|
        trip.employee_trips.each do |employee_trip|
          if employee_trip.canceled? || employee_trip.missed? || employee_trip.completed?
            #Do not send a notification in case of canceled or missed trip
            next
          end
          data = { id: employee_trip.id, data: { id: employee_trip.id, push_type: :vehicle_state_changed } }
          PushNotificationWorker.perform_async(employee_trip.employee.user_id, :vehicle_state_changed, data, :user)
        end        
      end
    end
  end

  def resolve_car_broke_down_notification(driver, trip)
    @notifications = Notification.where(:driver => driver).where(:trip => trip).where(:resolved_status => false).where(:message => ['car_break_down'])
    @notifications.each do |notification|
      notification.update!(resolved_status: true)
    end    
  end
end
