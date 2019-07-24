class ManageUsers::ManageOperatorDatatable
  def initialize(user = nil)
    @user = user
  end

  def as_json(options = {})
    {
        :data => data
    }
  end

  def data
    {
        "DT_RowId" => @user.entity.id,
        :name => @user.f_name.to_s + ' ' + @user.m_name.to_s + ' ' + @user.l_name.to_s,
        :f_name => @user.f_name.to_s,
        :m_name => @user.m_name.to_s,
        :l_name => @user.l_name.to_s,
        :email => @user.email,
        :phone => @user.phone,
        :status => @user.status&.capitalize,
        :entity_attributes => {
            :id => @user.entity.id,
            :company => @user.entity.logistics_company.name,
            :legal_name => @user.entity.legal_name,
            :pan => @user.entity.pan,
            :tan => @user.entity.tan,
            :business_type => @user.entity.business_type,
            :hq_address => @user.entity.hq_address,
            :service_tax_no => @user.entity.service_tax_no
        }
    }
  end
end
