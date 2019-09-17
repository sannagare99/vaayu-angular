class AddBaPortalIdToBa < ActiveRecord::Migration[5.0]
  def change
  	add_column :business_associates, :ba_portal_id, :integer
  end
end
