class AddDrivingLicenseDocToDriver < ActiveRecord::Migration[5.0]
  def up
    add_attachment :drivers, :driving_license_doc
  end

  def down
    remove_attachment :drivers, :driving_license_doc
  end
end
