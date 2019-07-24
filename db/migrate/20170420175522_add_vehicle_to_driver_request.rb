class AddVehicleToDriverRequest < ActiveRecord::Migration[5.0]
  def change
    add_reference :driver_requests, :vehicle, index: true
  end
end