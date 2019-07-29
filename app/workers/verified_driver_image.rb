class VerifiedDriverImage
  include Sidekiq::Worker
  sidekiq_options :retry => 3, :dead => false

  def perform(params)
    binding.pry
    trip = Trip.find(params["data"]["trip_id"]) if params["data"]["trip_id"].present? and params["data"].present?
    if trip.present? and params["data"]["result"] == 1
      trip.update_attributes(verified_driver_image: true)
      return trip
    end
  end
end