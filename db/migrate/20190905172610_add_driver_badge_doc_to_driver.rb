class AddDriverBadgeDocToDriver < ActiveRecord::Migration[5.0]
  def up
    add_attachment :drivers, :driver_badge_doc
  end

  def down
    remove_attachment :drivers, :driver_badge_doc
  end
end
