class AddAttachmentPhotoToVehicles < ActiveRecord::Migration
  def self.up
    change_table :vehicles do |t|
      t.attachment :photo
    end
  end

  def self.down
    remove_attachment :vehicles, :photo
  end
end
