class ManageUsers::ManageDriversDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view, drivers=[])
    @view = view
    search_input = params[:search_input]
    if search_input.present?
      @count = Driver.ransack(Searchables::DriverSearchable.new(params[:search_input]).send("by_#{params[:search_by]}")).result.joins(:user).order("f_name ASC, m_name ASC, l_name ASC").count
    else
      @count = Driver.count
    end
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: @count,
        iTotalDisplayRecords: @count,
        aaData: data
    }
  end

  private

  def data
    drivers.map do |driver|
      ManageUsers::ManageDriverDatatable.new(driver, params).data
    end
  end

  def drivers
    #Sort Logic - 
    # -1 means no notification 
    #  0 in case driver is on leave
    #  1 if driver has a compliance configurator notification
    #  2 if driver has a compliance provisioning notification
    #  3 if driver has a pending request

    start = params["start"]
    search_by = params[:search_by]
    search_input = params[:search_input]
    if search_input.present?
      @driver = Driver.eager_load([:user, :logistics_company, :business_associate, :vehicle, :site]).ransack(Searchables::DriverSearchable.new(params[:search_input]).send("by_#{params[:search_by]}")).result.joins(:user).order("f_name ASC, m_name ASC, l_name ASC").order('drivers.sort_status desc').order('drivers.created_at desc').offset(start).limit(per_page)
    else
      @driver = Driver.eager_load([:user, :logistics_company, :business_associate, :vehicle, :site]).order('drivers.sort_status desc').order('drivers.created_at desc').offset(start).limit(per_page)
    end

    @driver
    # @drivers = @drivers.order("created_at desc")
    # drivers = @drivers.sort do |a,b|
    #   active_checklist1 = a.checklists.active.first
    #   active_checklist2 = b.checklists.active.first

    #   status1 = -1
    #   status2 = -1

    #   if a.status == 'on_leave'
    #     status1 = 0  
    #   end

    #   if b.status == 'on_leave'
    #     status2 = 0
    #   end

    #   notification1 = a.compliance_notifications.active.order(updated_at: :desc).first
    #   # This notification to be shown below any car broke down or leave notification
    #   if notification1.present?
    #     notification1.checklist? ? status1 = 1 : status1 = 2
    #   end

    #   notification2 = b.compliance_notifications.active.order(updated_at: :desc).first
    #   # This notification to be shown below any car broke down or leave notification
    #   if notification2.present?
    #     notification2.checklist? ? status2 = 1 : status2 = 2
    #   end

    #   driver_request1 = DriverRequest.where(:driver => a).where('start_date > ?', Time.now).where(:request_state => [:cancel, :pending]).first
    #   if driver_request1.present?
    #     status1 = 3
    #   end

    #   driver_request2 = DriverRequest.where(:driver => a).where('start_date > ?', Time.now).where(:request_state => [:cancel, :pending]).first
    #   if driver_request2.present?
    #     status2 = 3
    #   end

    #   status2 <=> status1
    # end

    # drivers = Kaminari.paginate_array(drivers).page(page).per(per_page) if params[:paginate].nil?
    # drivers = drivers.page(page).per(per_page) if params[:paginate].nil?
    # drivers
  end

  def select_options
    {
        'entity_attributes.zone_id' =>  Zone.all.map{ |z| { "label": z.name, "value": z.id }},
        'entity_attributes.site_id' =>  Site.all.map{ |s| { "label": s.name, "value": s.id }},
        'entity_attributes.business_associate_id' =>  BusinessAssociate.all.map{ |b| { "label": b.name, "value": b.id }}
    }
  end

  def possible_sort_columns
    %w[id email]
  end
end
