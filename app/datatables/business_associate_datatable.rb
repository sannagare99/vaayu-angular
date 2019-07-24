class BusinessAssociateDatatable
  def initialize(business_associate = nil)
    @business_associate = business_associate
  end

  def as_json(options = {})
    {
        :data => data
    }
  end

  def data
    {
       "DT_RowId" => "#{BusinessAssociate::DATATABLE_PREFIX}-#{@business_associate.id}",
       :id => @business_associate.id,
       :legal_name => @business_associate.legal_name,
       :f_name => @business_associate.admin_f_name.to_s,
       :m_name => @business_associate.admin_m_name.to_s,
       :l_name => @business_associate.admin_l_name.to_s,
       :name => @business_associate.admin_f_name.to_s + ' ' + @business_associate.admin_m_name.to_s + ' ' + @business_associate.admin_l_name.to_s,
       :email => @business_associate.admin_email,
       :hq_address => @business_associate.hq_address,
       :business_type => @business_associate.business_type.to_s,
       :phone => @business_associate.admin_phone,
       :service_tax_no => @business_associate.service_tax_no
    }
  end
end
