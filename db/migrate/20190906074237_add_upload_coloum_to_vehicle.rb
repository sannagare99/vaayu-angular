class AddUploadColoumToVehicle < ActiveRecord::Migration[5.0]
  def up
    add_attachment :vehicles, :puc_doc
    add_attachment :vehicles, :commercial_permit_doc
    add_attachment :vehicles, :road_tax_doc
  end
  
  def down
    remove_attachment :vehicles, :puc_doc
    remove_attachment :vehicles, :commercial_permit_doc
    remove_attachment :vehicles, :road_tax_doc
  end
end
