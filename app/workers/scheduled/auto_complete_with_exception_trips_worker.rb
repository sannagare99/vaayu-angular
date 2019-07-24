class AutoCompleteWithExceptionTripsWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  sidekiq_options :retry => 3, :dead => false

  # Every day at 23:30
  recurrence { daily.hour_of_day(18).minute_of_hour(00) }

  def perform
    auto_complete_trips
  end

  def auto_complete_trips
  	non_active_status = ['created', 'assigned', 'assign_requested', 'assign_request_declined', 'assign_request_expired']
  	active_status = ['active']
  	# Fetch all employee trips for the current day where schedule id is not null
  	@non_active_trips = Trip.where(:status => non_active_status).where('scheduled_date < ?', Time.now.in_time_zone('Chennai') - 1.day)

  	@non_active_trips.each do |trip|
  		trip.update(:cancel_status => "System Completed the Trip")
  		trip.cancel_complete_trip
  	end

  	@active_trips = Trip.where('start_date < ?', Time.now.in_time_zone('Chennai') - 1.day).where(:status => active_status).where.not(book_ola: true)

  	@active_trips.each do |trip|
  		trip.update(:cancel_status => "System Completed the Trip")
  		trip.cancel_complete_trip
  	end
  end
end
