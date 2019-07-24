class TripShouldStart
  include Sidekiq::Worker
  sidekiq_options :retry => 3, :dead => false

  # check if driver is assigned,
  # if not -- reject manifest, set proper status
  # and send proper notifications
  def perform(trip_id, driver_id)
    trip = Trip.find(trip_id)
    driver = Driver.find(driver_id)

    if trip.blank? || driver.blank?
      return
    end

    if trip.assigned?
    	#Create a notification for driver should start trip
      @notification = Notification.where(:trip => trip, :driver => driver,  :message => 'trip_should_start', :resolved_status => false).first

      if @notification.blank?
    	 Notification.create!(:trip => trip, :driver => driver,  :message => 'trip_should_start', :resolved_status => false, :new_notification => true, :reporter => 'Moove System').send_notifications
      end
    end
  end
end