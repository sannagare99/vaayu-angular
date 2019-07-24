class TripRouteException < ApplicationRecord
  include AASM
  belongs_to :trip_route

  AUTOCLOSE = [ 'panic' ]
  SUSPEND = [ 'employee_no_show' ]

  enum exception_type: [ :not_on_board, :still_on_board, :panic, :driver_no_show, :employee_no_show ]

  aasm column: :status do
    state :open, initial: true
    state :closed

    event :resolved do
      transitions to: :closed, after: :save_resolved_date
    end

    # Close exception and mark trip route as missed
    event :resolved_by_operator do
      transitions to: :closed, after: [ :save_resolved_date, :save_resolved_by_operator_data ]
    end

  end

  delegate :driver, to: :trip_route
  delegate :trip, to: :trip_route

  after_create :autoclose_exceptions

  # All non-suspending exceptions
  scope :non_suspending, -> { where.not(exception_type: SUSPEND) }
  # Employee no show exceptions that are not closed
  scope :unresolved_suspending, -> { where(exception_type: SUSPEND).open }

  # Can this exception suspend all trip?
  def suspending?
    SUSPEND.include?(self.exception_type)
  end

  protected

  def save_resolved_date
    self.update!(resolved_date: Time.now)
  end

  # Close the exception if it is in autoclose list
  def autoclose_exceptions
    self.resolved! if AUTOCLOSE.include? self.exception_type
  end

  # Set trip route as missed
  def save_resolved_by_operator_data
    if self.employee_no_show?
      # SMSWorker.perform_async(driver.offline_phone, ENV['OPERATOR_NUMBER'], sms_push_data.to_json)
      trip_route.missed!
      if trip_route.trip.active?
        trip_route.trip.resequence_active_trip
      end

      push_data = {
          trip_id: trip_route.trip_id,
          trip_route_exception_id: self.id,
          trip_route_id: trip_route.id,
          exception_type: 'employee_no_show'
      }

      sms_push_data = push_data

      push_data = push_data.merge({data: push_data})
      push_data[:data].merge!(push_type: :operator_resolved_exception)
      PushNotificationWorker.perform_async(driver.user_id, :operator_resolved_exception, push_data)      
    end
  end
end
