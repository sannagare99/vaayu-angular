class VerifiedDriverImage
  include Sidekiq::Worker
  sidekiq_options :retry => 3, :dead => false

  def perform(params)
    trip = Trip.find(params[:id]) if params[:id].present?
    if trip.present? and params[:result].to_i == 1
      trip.update_attributes(verified_driver_image: true)
      return trip
    end
  end
end