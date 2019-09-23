class AddSiteIdToShifts < ActiveRecord::Migration[5.0]
  def change
    add_column :shifts, :site_id, :integer rescue nil
  end
end
