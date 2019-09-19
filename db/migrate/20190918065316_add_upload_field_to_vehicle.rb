class AddUploadFieldToVehicle < ActiveRecord::Migration[5.0]
  def up
    # add_attachment :vehicles, :authorization_certificate_doc
    add_attachment :vehicles, :vehicle_picture
    add_attachment :vehicles, :fitness_doc
  end
  
  def down
    # remove_attachment :vehicles, :authorization_certificate_doc
    remove_attachment :vehicles, :vehicle_picture
    remove_attachment :vehicles, :fitness_doc
  end
end