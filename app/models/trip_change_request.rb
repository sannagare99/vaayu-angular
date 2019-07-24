class TripChangeRequest < ApplicationRecord
  include AASM

  belongs_to :employee
  belongs_to :employee_trip

  enum request_type: [ :change, :cancel, :new_trip ]
  enum reason: [ :sick, :emergency, :scheduling_mistake ]
  enum trip_type: [ :check_in, :check_out ]

  aasm column: :request_state do
    state :created, initial: true

    state :approved
    state :declined

    event :approve, after_commit: [ :approve_request, :notify_employee ] do
      transitions from: :created, to: :approved
    end
    event :decline, after_commit: :notify_employee do
      transitions from: :created, to: :declined
    end
  end

  # MIN_AVAILABLE_TIME_TO_CHANGE = 2.hours
  DATATABLE_PREFIX = 'reque'

  validate :new_date_cannot_be_in_the_past, on: :create

  validates :trip_type, :new_date, presence: true, if: Proc.new{|r| r.new_trip? }
  validates :reason, :new_date, presence: true, if: Proc.new{|r| r.change? }
  validates :reason, presence: true, if: Proc.new{|r| r.cancel? }

  def trip_direction
    self.trip_type.blank? ? self.employee_trip.trip_type : self.trip_type
  end
  protected

  def approve_request
    case request_type.to_sym
      when :change        
        if employee_trip.trip.present?
          employee_trip.trip_canceled!
          #Create a new employee trip
          self.create_employee_trip!( date: new_date, trip_type: employee_trip.trip_type, employee: employee, bus_rider: employee.bus_travel)
          if Configurator.get('change_request_require_approval') == '1'
            reporter = "Operator: #{Current.user.full_name}"
            #TODO: Show Name of the approver here
            Notification.create!(:trip => employee_trip.trip, :employee => employee_trip.employee, :message => 'change_request_approved', :new_notification => true, :resolved_status => true, :reporter => "Moove System").send_notifications    
          end          
        else
          employee_trip.update(:date => self.new_date)
        end
      when :cancel
        # if employee_trip.trip.present? && employee_trip.trip.passengers == 1
        #   employee_trip.trip.cancel!
        # end
        # @TODO: here we should recount existent trip duration, eta etc
        # employee_trip.destroy
        # Cancel the trip route and complete trip in case everyone cancels the trip
        employee_trip.trip_canceled!
        #TODO: Fix this for Guard flow
        if employee_trip.trip.present?
          if employee_trip.trip.active?
            employee_trip.trip.resequence_active_trip
          else
            ret = employee_trip.trip.resequence_if_required

            #unassign driver if female exception could not be solved with resequencing
            if ret[:female_exception]
              if !employee_trip.trip.created?
                employee_trip.trip.unassign_driver_due_to_female_exception!
              end
            end
          end         
        end
      when :new_trip
        if self.shift
          #Employee has requested for a new shift time so add schedule date here
          self.create_employee_trip!( date: new_date, trip_type: trip_type, employee: employee, bus_rider: employee.bus_travel, schedule_date: Time.zone.parse("#{self.schedule_date} 10:00:00"))
        else          
          self.create_employee_trip!( date: new_date, trip_type: trip_type, employee: employee, bus_rider: employee.bus_travel)
        end
    end
  end

  def new_date_cannot_be_in_the_past    
    if request_type == 'cancel'
      if employee_trip.check_in?
        if employee_trip.trip.present?
          time = Configurator.get('cancel_time_check_in').to_i * 60
          if (employee_trip.date.in_time_zone("Kolkata") < Time.now + time) && Configurator.get('consider_non_compliant_cancel_as_no_show') == '1'
            employee_trip.update(:cancel_status => "Cancel via Policy Violation")
            # employee_trip.trip_canceled!
            # errors.add(:new_date, "Your trip has been marked as no show due to policy violation")
          end
        end
      else
        time = Configurator.get('cancel_time_check_out').to_i * 60
        if (employee_trip.date.in_time_zone("Kolkata") < Time.now + time) && Configurator.get('consider_non_compliant_cancel_as_no_show') == '1'
          employee_trip.update(:cancel_status => "Cancel via Policy Violation")
          # employee_trip.trip_canceled!
          # errors.add(:new_date, "Your trip has been marked as no show due to policy violation")
        end
      end
    end

    if request_type == 'change'
      if employee_trip.check_in?
        time = Configurator.get('change_time_check_in').to_i * 60
        if self.new_date.in_time_zone("Kolkata") < Time.now + time        
          errors.add(:new_date, "can't change check in trip in next #{formatted_duration(time)}")
        end      
      else
        time = Configurator.get('change_time_check_out').to_i * 60
        if self.new_date.in_time_zone("Kolkata") < Time.now + time
          errors.add(:new_date, "can't change check out trip in next #{formatted_duration(time)}")
        end        
      end
    end

    # if new_date.present? && new_date < Time.now + MIN_AVAILABLE_TIME_TO_CHANGE
    #   errors.add(:new_date, "can't be earlier than in two hours")
    # end
  end

  def notify_employee
    data = {
        trip_change_request_id: self.id,
        request_state: self.request_state,
        request_type: self.request_type,
        new_date: self.new_date.to_i,
        reason: self.reason,
    }

    if employee_trip

      data[:employee_trip] = {
          employee_trip_id: employee_trip.id,
          status: employee_trip.status,
          trip_type: employee_trip.trip_type,
          schedule_date: employee_trip.date.to_i,
          driver_arrive_date: employee_trip.approximate_driver_arrive_date.to_i,
      }

      if (driver = employee_trip.trip.try(:driver))
        data[:employee_trip][:driver] = {
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
    end

    data = data.merge({data: data})
    data[:data].merge!(push_type: :trip_change_request_answer)

    data.merge!(notification: {})
    if request_type == "cancel"
      data[:notification].merge!(title: "Cancel Request Answer")
    elsif request_type == "change"
      data[:notification].merge!(title: "Change Request Answer")
    else
      data[:notification].merge!(title: "New Ride Request Answer")
    end

    if request_state == "approved"
      data[:notification].merge!(body: "Your #{request_type} request has been approved")
    elsif request_state == "declined"
      data[:notification].merge!(body: "Your #{request_type} request has been declined")
    else
      data[:notification].merge!(body: "Your #{request_type} request has been created")
    end

    PushNotificationWorker.perform_async( employee.user_id, :trip_change_request_answer, data )
  end

  protected

  def formatted_duration(total_seconds)
    total_minutes = total_seconds / 60

    hours = (total_minutes / 60).to_i
    minutes = (total_minutes % 60).to_i

    time = ""
    if hours != 0
      time = time + "#{ hours } hours"
    end
    if minutes != 0
      time = time + " #{minutes} minutes"
    end

    time
  end
end
