class GetStartTripEtaWorker

  include Sidekiq::Worker
  sidekiq_options :retry => 0, :dead => false

  def perform(trip_id)
  	HTTParty.get(URI.escape("http://#{ENV['SERVER_URL']}/api/v3/trips/#{trip_id}/start_trip_eta"))
  end
  
end
