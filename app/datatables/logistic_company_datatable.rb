class LogisticCompanyDatatable
  def initialize(company = nil)
    @company = company
  end

  def as_json(options = {})
    {
        :data => data
    }
  end

  def data
    {
       "DT_RowId" => "#{LogisticsCompany::DATATABLE_PREFIX}-#{@company.id}",
       :id => @company.id,
       :name => @company.name,
       :hq_address => @company.hq_address,
       :business_type => @company.business_type,
       :pan => @company.pan,
       :service_tax_no => @company.service_tax_no,
       :phone => @company.phone,
    }
  end
end
