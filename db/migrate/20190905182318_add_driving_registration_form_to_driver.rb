class AddDrivingRegistrationFormToDriver < ActiveRecord::Migration[5.0]
  def up
    add_attachment :drivers, :driving_registration_form_doc
  end
  def down
    remove_attachment :drivers, :driving_registration_form_doc
  end
end
