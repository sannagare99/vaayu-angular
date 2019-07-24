class AutoRejectManifestWorker
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
      trip.assign_driver_request_expired!
      #TODO: Fix this for guard Flow.
      # trip.unassign_driver_info
      # trip.unassign_driver!
      # Create a notification for this trip
      @notification = Notification.where(:trip => trip, :message => 'driver_didnt_accept_trip', :resolved_status => false).first
      if @notification.blank?
        Notification.create!(:trip => trip, :driver => trip.driver,  :message => 'driver_didnt_accept_trip', :resolved_status => false, :new_notification => true, :reporter => 'Moove System').send_notifications
      end
    end
  end
  
end
