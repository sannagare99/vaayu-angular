class AddInsuranceDocToVehicle < ActiveRecord::Migration[5.0]
  def up
    add_attachment :vehicles, :insurance_doc
  end
  def down
    remove_attachment :vehicles, :insurance_doc
  end
end