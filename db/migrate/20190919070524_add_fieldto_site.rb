class AddFieldtoSite < ActiveRecord::Migration[5.0]
  def change
  	add_column :sites, :created_by, :string
  	add_column :sites, :updated_by, :string
  	add_column :sites, :admin_name, :string
  	add_column :sites, :admin_email_id, :string
  end
end
