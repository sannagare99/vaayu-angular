class ManageUsers::ManageTransportDeskManagerDatatable
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
        :id => @user.entity.id,
        :name => @user.f_name.to_s + ' ' +@user.m_name.to_s+ ' ' + @user.l_name.to_s,
        :f_name => @user.f_name.to_s,
        :m_name => @user.m_name.to_s,
        :l_name => @user.l_name.to_s,
        :email => @user.email,
        :phone => @user.phone,
        :status => @user.status.to_s.split("_").join(" ").capitalize,
        :entity_attributes => {
            :id => @user.entity.id,
            :company => @user.entity.employee_company&.name,
        }
    }
  end
end