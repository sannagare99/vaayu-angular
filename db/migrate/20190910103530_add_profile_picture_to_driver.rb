class AddProfilePictureToDriver < ActiveRecord::Migration[5.0]
  def up
    add_attachment :drivers, :profile_picture
  end

  def down
    remove_attachment :drivers, :profile_picture
  end
end
