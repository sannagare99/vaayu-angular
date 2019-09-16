class AddFieldsToBusinessAssociates < ActiveRecord::Migration[5.0]
  def change
  	add_column :business_associates, :sap_code, :string
  	add_column :business_associates, :esic_code, :string
  	add_column :business_associates, :pf_number, :string
  	add_column :business_associates, :aadhar_number, :string
  	add_column :business_associates, :credit_days, :integer
  	add_column :business_associates, :credit_amount, :integer
  	add_column :business_associates, :bgc_date, :datetime
  	add_column :business_associates, :credit_days_start, :datetime

  	add_column :business_associates, :owned_fleet, :integer
  	add_column :business_associates, :managed_fleet, :integer
  	add_column :business_associates, :turn_over, :integer
  	add_column :business_associates, :partnership_status, :string
  	add_column :business_associates, :business_area_id, :integer
  	add_column :business_associates, :address, :string
  	add_column :business_associates, :address_2, :string

  	add_column :business_associates, :alternate_phone, :string
  	add_column :business_associates, :fax_no, :string
  	add_column :business_associates, :website, :string
  	add_column :business_associates, :address_3, :text
  	add_column :business_associates, :bank_name, :string
  	add_column :business_associates, :bank_no, :string
  	add_column :business_associates, :ifsc_code, :string
  	add_column :business_associates, :city_of_operation, :string
  	add_column :business_associates, :state_of_operation, :string

  	add_column :business_associates, :msmed_certificate_doc_url, :string
  	add_column :business_associates, :photo_url, :string
  	add_column :business_associates, :owner_photo_url, :string
  	add_column :business_associates, :created_by, :string
  	add_column :business_associates, :updated_by, :string


  end
end
