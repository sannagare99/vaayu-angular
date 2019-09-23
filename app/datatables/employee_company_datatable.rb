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
       :logistics_company_id => @employee_company.logistics_company&.id,
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
