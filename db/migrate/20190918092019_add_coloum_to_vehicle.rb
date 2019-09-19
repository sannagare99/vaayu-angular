class AddColoumToVehicle < ActiveRecord::Migration[5.0]
  def up
  	add_attachment :vehicles, :authorization_certificate_doc
  end

  def down
  	remove_attachment :vehicles, :authorization_certificate_doc
  end
end
