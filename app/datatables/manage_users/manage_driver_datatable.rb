class ManageUsers::ManageDriverDatatable
  include ApplicationHelper
  include ActionView::Helpers::TextHelper

  def initialize(driver = nil, options={})
    @driver = driver
    @search_params = options
    # @active_checklist = @driver.user.entity.checklists.active.first
    @driver_request = DriverRequest.where(:driver => @driver).where('start_date > ?', Time.now).where(:request_state => [:cancel, :pending]).first
  end

  def as_json(options = {})
    {
        :data => data
    }
  end

  def data
    {
        "DT_RowId" => @driver.id,
        :id => @driver.id,
        :name => highlight_text([@driver.user.f_name.to_s, @driver.user.m_name.to_s, @driver.user.l_name.to_s].reject(&:blank?).join(" ")),
        :f_name => @driver.user.f_name.to_s,
        :m_name => @driver.user.m_name.to_s,
        :l_name => @driver.user.l_name.to_s,
        :email => highlight_text(@driver.user.email),
        :phone => highlight_text(@driver.user.phone),
        :username => @driver.user.username,
        :status => @driver.user.pending? ? "-" : @driver.user.status.titleize,
        :invite_count => @driver.user.invite_count,
        :last_active_time => @driver.user.pending? ? "-" : @driver.user.last_active_time.strftime("%m/%d/%Y %H:%M"),
        :driver_request => driver_request,
        :leave_request_dates => leave_request_dates,
        :on_leave_dates => on_leave_dates,
        :checklist_attributes => { id: @driver&.active_checklist_id, status: checklist_status[:title], notification_type: checklist_status[:notification] },
        :entity_attributes => {
            :id => @driver.id,
            :company => @driver.logistics_company&.name,
            :business_associate => highlight_text(@driver.business_associate&.name),
            :business_associate_id => @driver.business_associate&.id,
            :badge_number => @driver.badge_number,
            :licence_number => highlight_text(@driver.licence_number&.last(6)),
            :site => @driver.site&.name,
            :vehicle_number => @driver.vehicle&.plate_number,
            :site_id => @driver.site&.id,
            :badge_issue_date => @driver.badge_issue_date,
            :badge_expire_date => @driver.badge_expire_date,
            :local_address => @driver.local_address,
            :permanent_address => @driver.permanent_address,
            :aadhaar_number => highlight_text(@driver.aadhaar_number),
            :aadhaar_mobile_number => @driver.aadhaar_mobile_number,
            :licence_validity => @driver.licence_validity,
            :verified_by_police => human_boolean(@driver.verified_by_police),
            :uniform => @driver.uniform,
            :licence => @driver.licence,
            :badge => @driver.badge,
            :status => @driver.driver_status.to_s.split("_").join(" ").capitalize
        }
    }
  end

  def highlight_text(txt)
    return txt if @search_params[:highlight].present? && @search_params[:highlight] == "false"
    @search_params[:search_input].present? && txt.present? ? highlight(txt, @search_params[:search_input]) : txt
  end

  def driver_request
    @driver_request
  end

  def leave_request_dates
    if @driver_request.present?
      @driver_request.start_date.strftime("%m/%d") + " " + @driver_request.end_date.strftime("%m/%d")
    end
  end

  def on_leave_dates
    if @driver.status == 'on_leave'
      @driver_request_leave = DriverRequest.where(:driver => @driver).where('start_date < ? AND end_date > ?', Time.now, Time.now).where(:request_state => [:approved]).first 
      if @driver_request_leave.present?
        @driver_request_leave.start_date.strftime("%m/%d") + " " + @driver_request_leave.end.strftime("%m/%d")
      end
    end
  end

  def checklist_status
    {title: @driver.compliance_notification_message, notification: @driver.compliance_notification_type}
  end
end
