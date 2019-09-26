class AddFieldToBa < ActiveRecord::Migration[5.0]
  def change
  	add_column :business_associates, :baId, :string
  	add_column :business_associates, :pin_code  , :string
  	add_column :business_associates, :company_name  , :string
  	add_column :business_associates, :contact_person  , :string
  	add_column :business_associates, :cin_no  , :string
  	add_column :business_associates, :landline  , :string
  	add_column :business_associates, :contact_person_mobile  , :string
  	add_column :business_associates, :approved_till_date  , :datetime
  	add_column :business_associates, :old_sap_master_code  , :string
  	add_column :business_associates, :new_sap_master_code  , :string
  	add_column :business_associates, :ba_verified_on  , :datetime
  	add_column :business_associates, :state_code  , :string
  	add_column :business_associates, :is_gst, :boolean, default: false
  end
end