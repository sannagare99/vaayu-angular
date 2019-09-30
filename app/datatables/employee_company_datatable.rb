class EmployeeCompanyDatatable
  def initialize(employee_company = nil)
    @employee_company = employee_company
  end

  def as_json(options = {})
    {
        :data => data
    }
  end

  def data
    {
       "DT_RowId" => "#{EmployeeCompany::DATATABLE_PREFIX}-#{@employee_company.id}",
       :id => @employee_company.id,
       :name => @employee_company.name,
       :hq_address => @employee_company.hq_address,
       :business_type => @employee_company.business_type,
       :pan => @employee_company.pan,
       :service_tax_no => @employee_company.service_tax_no,
       :zone => @employee_company.zone, #Rushikesh made changes here
       :category => @employee_company.category,
       :billing_to => @employee_company.billing_to,
       :home_address_contact_name => @employee_company.home_address_contact_name,
       :home_address_address_1 => @employee_company.home_address_address_1,
       :home_address_address_2 => @employee_company.home_address_address_2,
       :home_address_address_3 => @employee_company.home_address_address_3,
       :home_address_pin => @employee_company.home_address_pin,
       :home_address_state => @employee_company.home_address_state,
       :home_address_city => @employee_company.home_address_city,
       :home_address_phone_1 => @employee_company.home_address_phone_1,
       :home_address_phone_2 => @employee_company.home_address_phone_2,
       :home_address_business_area => @employee_company.home_address_business_area,
       :home_address_pan_no => @employee_company.home_address_pan_no,
       :home_address_gstin_no => @employee_company.home_address_gstin_no,
       :registered_contact_name => @employee_company.registered_contact_name,
       :registered_address1 => @employee_company.registered_address1,
       :registered_address2 => @employee_company.registered_address2,
       :registered_address3 => @employee_company.registered_address3,
       :registered_pin => @employee_company.registered_pin,
       :registered_state => @employee_company.registered_state,
       :registered_city => @employee_company.registered_city,
       :registered_phone1 => @employee_company.registered_phone1,
       :registered_phone2 => @employee_company.registered_phone2,
       :registered_business_area => @employee_company.registered_business_area,
       :registered_pan_no => @employee_company.registered_pan_no,
       :registered_gstin_no => @employee_company.registered_gstin_no,
       :logistics_company => @employee_company.logistics_company&.name,
       :standard_price => @employee_company.standard_price,
       :invoice_frequency => @employee_company.invoice_frequency,
       :invoice_frequency_id => @employee_company.invoice_frequency,
       :pay_period => @employee_company.pay_period,
       :pay_period_id => @employee_company.pay_period,
       :time_on_duty_limit => @employee_company.time_on_duty_limit,
       :distance_limit => @employee_company.distance_limit,
       :rate_by_time => @employee_company.rate_by_time,
       :service_tax_percent => @employee_company.service_tax_percent,
       :rate_by_distance => @employee_company.rate_by_distance,
       :agreement_date => @employee_company.agreement_date,
       :swachh_bharat_cess => @employee_company.swachh_bharat_cess,
       :krishi_kalyan_cess => @employee_company.krishi_kalyan_cess,
       :profit_centre => @employee_company.profit_centre
    }
  end
end
