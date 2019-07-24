class NotificationsDatatable
  include DatatablePagination

  delegate :params, to: :@view

  def initialize(view, user = nil)
    @view = view
    @user = user
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        aaData: data,
        iTotalRecords: @notifications_count,
        iTotalDisplayRecords: @notifications_count
    }
  end

  def get_notifications
    # @n1 = Notification.find_by_sql("select trip_id from notifications 
    #     where notifications.status = '0'
    #     order by notifications.resolved_status asc, 
    #     notifications.sequence desc, notifications.created_at desc").to_a.uniq{|x| x.trip_id};

    # @n1 = Notification.find_by_sql("select distinct trips.id from trips left join drivers on
    #       (trips.driver_id = drivers.id) left join vehicles on (trips.vehicle_id = vehicles.id) left join
    #       trip_routes on (trips.id = trip_routes.trip_id) left join employee_trips on
    #       (trip_routes.employee_trip_id = employee_trips.id) left join employees on
    #       (employee_trips.employee_id = employees.id) left join users on ((users.entity_id = drivers.id and
    #       users.entity_type = 'Driver') or ((users.entity_id = employees.id and users.entity_type =
    #       'Employee'))) where trips.status in (#{trip_status}) and trips.bus_rider in (#{bus_rider}) and
    #       (replace(lower(CONCAT_WS('', users.f_name, users.m_name, users.l_name)), ' ', '') like
    #       lower(replace('%#{search}%', ' ', '')) or replace(lower(vehicles.plate_number), ' ', '') LIKE
    #       replace('%#{search}%', ' ', '')) and trips.trip_type in (#{direction}) order by find_in_set (trips.status,
    #       #{trip_status_set}) , id desc limit #{per_page} offset #{start}").to_a.uniq{|x| x.trip_id};
    # no_tr = []
    # @n1.each do |n|
    #   no_tr.push(n.trip_id)
    # end
    # @notification = no_tr

    # @notification
    start = params['start']
    trip_status = filter_params['trip_status']
    direction = filter_params['direction']
    bus_rider = filter_params['busRider']
    trip_status = filter_params['tripStatus']
    start_date = filter_params['startDate']
    end_date = filter_params['endDate']
    search = filter_params['search']
    receiver = '(0,1,2)'
    logistics_company_query = ""
    if !start_date.blank? && !end_date.blank?
      date_query = " and employee_trips.date between '#{start_date}' and '#{end_date}' "
      trips_date_query = " and employee_trips.date between '#{start_date}' and '#{end_date}' "
    end

    flag = params['trip_status'] == '6' && params['bus_rider'] == '2' && params['direction'] == '2' && start_date.blank? && end_date.blank?
    case @user.role
      when 'employer', 'transport_desk_manager'
        company = @user.entity.employee_company.logistics_company
        # @notification = nil

        # @notification = @notification.except(:includes).pluck('distinct(notifications.trip_id)')
        receiver = '(1,2)'
        logistics_company_query = " and drivers.logistics_company_id = #{company.id}"
      when 'operator'
        company = @user.entity.logistics_company
        @notification = nil
        # if filter_params['startDate'].blank?
        #   @notification = Notification.eager_load([:driver, :trip => [:employee_trips]]).where(:receiver => [0,2], 'notifications.status' => 0,'drivers.logistics_company_id' => company.id).where('trips.trip_type'=> filter_params['direction']).where('trips.bus_rider' => filter_params['busRider']).where('trips.status'=> filter_params['tripStatus']).order('notifications.trip_id desc')
        # else
        #   @notification = Notification.eager_load([:driver, :trip => [:employee_trips]]).where(:receiver => [0,2], 'notifications.status' => 0,'drivers.logistics_company_id' => company.id).where('trips.trip_type'=> filter_params['direction']).where('employee_trips.date' => filter_params['startDate']..filter_params['endDate']).where('trips.bus_rider' => filter_params['busRider']).where('trips.status'=> filter_params['tripStatus']).order('notifications.trip_id desc')
        # end
        receiver = '(0,2)'
        logistics_company_query = " and drivers.logistics_company_id = #{company.id}"
        # @notification = @notification.except(:includes).pluck('distinct(notifications.trip_id)')
      when 'admin'
        # @notification = nil
        # if filter_params['startDate'].blank?
        #   @notification = Notification.eager_load(:trip => [:employee_trips]).where('notifications.status' => 0).where('trips.trip_type'=> filter_params['direction']).where('trips.bus_rider' => filter_params['busRider']).where('trips.status'=> filter_params['tripStatus']).order('notifications.trip_id desc') 
        # else
        #   @notification = Notification.eager_load(:trip => [:employee_trips]).where('notifications.status' => 0).where('trips.trip_type'=> filter_params['direction']).where('employee_trips.date' => filter_params['startDate']..filter_params['endDate']).where('trips.bus_rider' => filter_params['busRider']).where('trips.status'=> filter_params['tripStatus']).order('notifications.trip_id desc')
        # end        
        # @notification = @notification.except(:includes).pluck('distinct(notifications.trip_id)')
      else
        []
    end

    if search.blank?
      search_query = " where "
      trips_search_query = " where "
    else
      search_query = " left join drivers on (notifications.driver_id = drivers.id) 
                        left join employees on (employee_trips.employee_id = employees.id) 
                        left join vehicles on (trips.vehicle_id = vehicles.id)
                        left join users on ((users.entity_id = drivers.id and users.entity_type = 'Driver') 
                        or (users.entity_id = employees.id and users.entity_type = 'Employee')) where 
                        (replace(lower(CONCAT_WS('', users.f_name, users.m_name, users.l_name)), ' ', '') like 
                        lower(replace('%#{search}%', ' ', '')) or replace(lower(vehicles.plate_number), ' ', '') LIKE 
                        replace('%#{search}%', ' ', '')) and "

      trips_search_query = " left join drivers on
                        (trips.driver_id = drivers.id) left join vehicles on (trips.vehicle_id = vehicles.id) 
                        left join employees on
                        (employee_trips.employee_id = employees.id) left join users on ((users.entity_id = drivers.id and
                        users.entity_type = 'Driver') or ((users.entity_id = employees.id and users.entity_type =
                        'Employee'))) where (replace(lower(CONCAT_WS('', users.f_name, users.m_name, users.l_name)), ' ', '') like
                        lower(replace('%#{search}%', ' ', '')) or replace(lower(vehicles.plate_number), ' ', '') LIKE
                        replace('%#{search}%', ' ', '')) and "                             
    end

    if !(flag)
      @notification = Notification.find_by_sql("select distinct(notifications.trip_id) from notifications 
                left join trips on (notifications.trip_id = trips.id) 
                left join employee_trips on (trips.id = employee_trips.trip_id)
                #{search_query} 
                notifications.resolved_status = 0 and notifications.receiver in #{receiver} and notifications.status = 0 
                and notifications.trip_id is not null 
                and trips.status in (#{trip_status}) and trips.bus_rider in (#{bus_rider}) 
                #{date_query}
                and trips.trip_type in (#{direction}) order by notifications.resolved_status asc,
                notifications.sequence desc, notifications.id desc limit #{per_page} offset #{start}")


      @notifications_count = Notification.count_by_sql("select count(distinct(notifications.trip_id)) from notifications 
                left join trips on (notifications.trip_id = trips.id) 
                left join employee_trips on (trips.id = employee_trips.trip_id)
                #{search_query} 
                notifications.receiver in #{receiver} and notifications.status = 0 
                and notifications.trip_id is not null 
                and trips.status in (#{trip_status}) and trips.bus_rider in (#{bus_rider}) 
                #{date_query}
                and trips.trip_type in (#{direction})")
    else
      @notification = Notification.find_by_sql("select distinct(notifications.trip_id) from notifications where 
                notifications.resolved_status = 0 and notifications.receiver in #{receiver} and notifications.status = 0 
                and notifications.trip_id is not null 
                order by notifications.resolved_status asc,
                notifications.sequence desc, notifications.id desc limit #{per_page} offset #{start}")


      @notifications_count = Notification.count_by_sql("select count(distinct(notifications.trip_id)) from notifications where 
                notifications.receiver in #{receiver} and notifications.status = 0 
                and notifications.trip_id is not null")      
    end

    trip_ids = []
    @notification.each do |notification|
      trip_ids.push(notification.trip_id)
    end

    # @notification_group = Notification.find_by_sql("select * from notifications 
    #   left outer join trips on trips.id = notifications.trip_id
    #   where trip_id in (#{trip_ids}) 
    #   order by ")

    if @notification.count < per_page
      if !(flag)
        unresolved_count = Notification.count_by_sql("select count(distinct(notifications.trip_id)) from notifications 
                  left join trips on (notifications.trip_id = trips.id) 
                  left join employee_trips on (trips.id = employee_trips.trip_id)
                  #{search_query} 
                  notifications.resolved_status = 0 and notifications.receiver in #{receiver} and notifications.status = 0 
                  and notifications.trip_id is not null 
                  and trips.status in (#{trip_status}) and trips.bus_rider in (#{bus_rider}) 
                  #{date_query}
                  and trips.trip_type in (#{direction})")        
      else
        unresolved_count = Notification.count_by_sql("select count(distinct(notifications.trip_id)) from notifications where 
                  notifications.resolved_status = 0 and notifications.receiver in #{receiver} and notifications.status = 0 
                  and notifications.trip_id is not null ")        
      end


      per_page_resolved_trips = 15
      offset = 0
      if @notification.count > 0
        per_page_resolved_trips = per_page.to_i + start.to_i - unresolved_count
      else
        offset = start.to_i - unresolved_count
      end

      if !(flag)
        @resolved_notification = Notification.find_by_sql("select distinct(notifications.trip_id) from notifications  
                  left join trips on (notifications.trip_id = trips.id) 
                  left join employee_trips on (trips.id = employee_trips.trip_id)
                  where notifications.trip_id not in 
                  (select distinct(notifications.trip_id) from notifications 
                  left join trips on (notifications.trip_id = trips.id) 
                  left join employee_trips on (trips.id = employee_trips.trip_id)
                  #{search_query} 
                  notifications.resolved_status = 0 and notifications.receiver in #{receiver} and notifications.status = 0 
                  and notifications.trip_id is not null 
                  and trips.status in (#{trip_status}) and trips.bus_rider in (#{bus_rider}) 
                  #{date_query}
                  and trips.trip_type in (#{direction})) and notifications.receiver in #{receiver} and notifications.status = 0 
                  and notifications.trip_id is not null 
                  and trips.status in (#{trip_status}) and trips.bus_rider in (#{bus_rider}) 
                  #{date_query}
                  and trips.trip_type in (#{direction}) order by notifications.id desc 
                  limit #{per_page_resolved_trips} offset #{offset}")
      else
        @resolved_notification = Notification.find_by_sql("select distinct(notifications.trip_id) from notifications where trip_id not in 
                  (select distinct(notifications.trip_id) from notifications where 
                  notifications.resolved_status = 0 and notifications.receiver in #{receiver} and notifications.status = 0 
                  and notifications.trip_id is not null) and notifications.receiver in #{receiver} and notifications.status = 0 
                  and notifications.trip_id is not null order by notifications.id desc 
                  limit #{per_page_resolved_trips} offset #{offset}")        
      end

      @resolved_notification.each do |rn|
        trip_ids.push(rn.trip_id)
      end
    end

    @notification_group = Notification.includes(:driver => [:user], :employee => [:user], :trip => [:vehicle, :site, :employee_trips])
      .where(trip_id: trip_ids).order('case when notifications.resolved_status = 0 THEN 
      notifications.sequence end desc, case when notifications.resolved_status = 0 THEN 
      notifications.id end desc, case when notifications.resolved_status = 1 THEN 
      notifications.id end desc').group_by(&:group_by_trip_id)
    # @resolved_notification = Notification.find_by_sql("select notifications.trip_id from notifications 
    #           left join trips on (notifications.trip_id = trips.id) 
    #           left join employee_trips on (trips.id = employee_trips.trip_id) 
    #           #{search_query}
    #           notifications.resolved_status = 1 and notifications.receiver in #{receiver} and 
    #           notifications.status = 0 #{logistics_company_query}
    #           and trips.status in (#{trip_status}) and trips.bus_rider in (#{bus_rider}) 
    #           #{date_query} 
    #           and trips.trip_type in (#{direction}) order by notifications.id desc").to_a.uniq{|x| x.trip_id};                        


    # @trip_ids = Trip.find_by_sql("select distinct trips.id as trip_id from trips 
    #   left join notifications on 
    #   (notifications.trip_id = trips.id)
    #   left join employee_trips on (trips.id = employee_trips.trip_id)
    #   #{trips_search_query}
    #   notifications.id is not null and trips.bus_rider in (#{bus_rider}) and
    #   trips.trip_type in (#{direction}) #{trips_date_query} order by trips.id desc").to_a

    # @trip_ids = []
    # @unresolved_trip_ids = @trip_ids - @unresolved_notification.uniq

    # @badge_count = @unresolved_notification.uniq.count

    # @notification = @unresolved_notification.uniq + @unresolved_trip_ids.uniq

    # notification_trips = []
    # @notification.each do |n|
    #   notification_trips.push(n.trip_id)
    # end
    # @notification = notification_trips.uniq

    @notification_group
  end

  private

  # get params from date filter
  def filter_params
    startDate = Time.zone.parse(params['startDate']).in_time_zone('UTC') unless params['startDate'].blank?
    endDate = Time.zone.parse(params['endDate']).in_time_zone('UTC') unless params['endDate'].blank?
    direction = params['direction'] == '2' ? "0, 1" : params['direction']

    trip_status = 'created'

    if params['trip_status'] == '0'
      trip_status = "'created'"
    elsif params['trip_status'] == '1'
      trip_status = "'assign_requested','assign_request_expired','assign_request_declined'"
    elsif params['trip_status'] == '2'
      trip_status = "'assigned'"
    elsif params['trip_status'] == '3'
      trip_status = "'active'"
    elsif params['trip_status'] == '4'
      trip_status = "'canceled'"
    elsif params['trip_status'] == '5'
      trip_status = "'completed'"
    elsif params['trip_status'] == '6'
      trip_status = "'created','assign_request_declined','accepted','assigned','assign_request_expired','assign_requested','active','completed','canceled'"
    end

    if params['bus_rider'] == '2'
      busRider = '0,1'
    elsif params['bus_rider'] == '1'
      busRider = '1'
    else
      busRider = '0'
    end

    {
        'startDate' => startDate,
        'endDate'=> endDate,
        'direction' => direction,
        'busRider' => busRider,
        'tripStatus' => trip_status,
        'search' => params['search']
    }
  end

  def data
    notifications = all_notifications
    notifications.map do |notification|
      NotificationDatatable.new(notification.last, @user, @badge_count).data
    end
  end

  def all_notifications
    get_notifications
  end

  # def fetch_notifications
  #   notifications = get_notifications
  #   notifications = notifications.page(page).per(per_page)
  #   notifications
  # end
  
  def possible_sort_columns
    %w[id]
  end
end