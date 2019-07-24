class AutoSendReAssignmentPush
  include Sidekiq::Worker
  sidekiq_options :retry => 3, :dead => false

  # check if driver is assigned,
  # if not -- reject manifest, set proper status
  # and send proper notifications
  def perform(trip_id, driver_id)
    trip = Trip.find(trip_id)

    if trip.blank?
      return
    end

    if trip.assign_requested? && trip.driver_id == driver_id
      trip.resend_notity_driver_about_assignment
    end
  end
  
end