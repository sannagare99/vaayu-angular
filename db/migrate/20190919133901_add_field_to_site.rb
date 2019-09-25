class AddFieldToSite < ActiveRecord::Migration[5.0]
  def change
  	add_column :sites, :branch_name, :string
  	add_column :sites, :site_code, :string
  	add_column :sites, :contact_name, :string

  	add_column :sites, :address_1, :text
  	add_column :sites, :address_2, :text
  	add_column :sites, :address_3, :text

  	add_column :sites, :pin, :string
  	add_column :sites, :state, :string
  	add_column :sites, :city, :string

  	add_column :sites, :phone_1, :string
  	add_column :sites, :phone_2, :string
  	add_column :sites, :business_area, :string

  	add_column :sites, :pan_no, :string
  	add_column :sites, :gstin_no, :string
  	add_column :sites, :cost_centre, :string

  	add_column :sites, :profit_centre , :string
  	add_column :sites, :gl_acc_no, :string

  	add_column :sites, :party_code, :string
  	add_column :sites, :party_contact_name, :string
  	add_column :sites, :party_address_1, :string

  	add_column :sites, :party_address_2, :string
  	add_column :sites, :party_address_3, :string
  	add_column :sites, :party_pin, :string

  	add_column :sites, :party_city, :string
  	add_column :sites, :party_state, :string
  	add_column :sites, :party_phone_1, :string

  	add_column :sites, :party_phone_2, :string
  	add_column :sites, :party_business_area, :string
  	add_column :sites, :party_pan_no, :string
  	add_column :sites, :party_gstin_no, :string
  end
end
