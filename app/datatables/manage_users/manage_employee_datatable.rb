class ManageUsers::ManageEmployeeDatatable
  include ActionView::Helpers::TextHelper

  def initialize(user = nil, options={})
    @user = user
    @search_params = options
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
        :f_name => @user.f_name.to_s,
        :m_name => @user.m_name.to_s,
        :l_name => @user.l_name.to_s,
        :name => highlight_text([@user.f_name.to_s, @user.m_name.to_s, @user.l_name.to_s].reject(&:blank?).join(" ")),
        :username => @user.username,
        :email => highlight_text(@user.email),
        :phone => highlight_text(@user.phone),
        :avatar => @user.avatar.url(:medium),
        :status => get_status(@user.status.to_s.split("_").join(" ").capitalize),
        :invite_count => @user.invite_count.to_i,
        :entity_attributes => {
            :id => @user.entity.id,
            :company => @user.entity.employee_company&.name,
            :employee_id => highlight_text(@user.entity.employee_id),
            :gender => @user.entity.gender.to_s.first.capitalize,
            :site => highlight_text(@user.entity.site&.name),
            :site_id => @user.entity.site&.id,
            :zone => @user.entity.zone&.name,
            :zone_id => @user.entity.zone&.id,
            :home_address => highlight_text(@user.entity.home_address),
            :date_of_birth => @user.entity.date_of_birth
        }
    }
  end

  def highlight_text(txt)
    return txt if @search_params[:highlight].present? && @search_params[:highlight] == "false"
    @search_params[:search_input].present? && txt.present? ? highlight(txt, @search_params[:search_input]) : txt
  end

  def get_status(txt)
    status = txt
    if txt == 'Pending'
      status = 'Invited'      
    end
    status
  end
end
