class ScheduleUpdateTripDistanceDurationWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 3, :dead => false

  # check if driver is assigned,
  # if not -- reject manifest, set proper status
  # and send proper notifications
  def perform(trip_id)
    trip = Trip.find(trip_id)

    if !trip.blank?
    	trip.update_trip_distance_duration
    end
  end
end