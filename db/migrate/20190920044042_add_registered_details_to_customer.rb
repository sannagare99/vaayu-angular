class AddRegisteredDetailsToCustomer < ActiveRecord::Migration[5.0]
  def change
  	add_column :employee_companies, :registered_contact_name , :string
  	add_column :employee_companies, :registered_address1 , :string
  	add_column :employee_companies, :registered_address2 , :string
  	add_column :employee_companies, :registered_address3 , :string
  	add_column :employee_companies, :registered_pin , :string
  	add_column :employee_companies, :registered_state , :string
  	add_column :employee_companies, :registered_city , :string
  	add_column :employee_companies, :registered_phone1 , :string
  	add_column :employee_companies, :registered_phone2 , :string
  	add_column :employee_companies, :registered_business_area  , :string
  	add_column :employee_companies, :registered_pan_no  , :string
  	add_column :employee_companies, :registered_gstin_no  , :string
  end
end
