class TripRostersDatatable
  include DatatablePagination

  delegate :params, to: :@view

  def initialize(view, user = nil)
    @view = view
    @user = user
  end

  def as_json(options = {})
    count = get_count
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data
    }
  end

  def get_count

    direction = filter_params['direction']
    bus_rider = filter_params['busRider']
    trip_status = filter_params['trip_status']
    search = params['search'].delete(' ').downcase

    if params['search'].blank?
      if filter_params["startDate"].blank? && filter_params["endDate"].blank?
        # @count = Trip.count_by_sql("select count(distinct trips.id) from trips 
        #     where trips.status in (#{trip_status}) and trips.bus_rider in (#{bus_rider}) 
        #     and trips.trip_type in (#{direction})")
        @count = Trip.where(:status => trip_status, :bus_rider => bus_rider, :trip_type => direction).count
      else
        start_date = filter_params['startDate']
        end_date = filter_params['endDate']
        @count = Trip.includes(:employee_trips).where('trips.status' => trip_status, 
          'trips.bus_rider' => bus_rider, 'trips.trip_type' => direction, 
          'employee_trips.date' => start_date..end_date).count
        # @count = Trip.count_by_sql("select count(distinct trips.id) from trips
        #     left join employee_trips on (trips.id = employee_trips.trip_id)  
        #     where trips.status in (#{trip_status}) and trips.bus_rider in (#{bus_rider}) 
        #     and trips.trip_type in (#{direction}) and employee_trips.date 
        #     between '#{start_date}' and '#{end_date}'")
      end
    else
      if filter_params["startDate"].blank? && filter_params["endDate"].blank?
        @count = Trip.joins(:vehicle, :trip_routes, :employee_trips => [:employee => [:user]], :driver => [:user])
            .where('trips.status' => trip_status, 
              'trips.bus_rider' => bus_rider, 
              'trips.trip_type' => direction)
            .where("(replace(lower(CONCAT_WS('', users.f_name, users.m_name, users.l_name)), ' ', '') like
                lower(replace('%#{search}%', ' ', '')) or replace(lower(vehicles.plate_number), ' ', '') LIKE
                replace('%#{search}%', ' ', ''))")
            .count
        # @count = Trip.count_by_sql("select count(distinct trips.id) from trips left join drivers on
        #     (trips.driver_id = drivers.id) left join vehicles on (trips.vehicle_id = vehicles.id) left join
        #     trip_routes on (trips.id = trip_routes.trip_id) left join employee_trips on
        #     (trip_routes.employee_trip_id = employee_trips.id) left join employees on
        #     (employee_trips.employee_id = employees.id) left join users on ((users.entity_id = drivers.id and
        #     users.entity_type = 'Driver') or ((users.entity_id = employees.id and users.entity_type =
        #     'Employee'))) where trips.status in (#{trip_status}) and trips.bus_rider in (#{bus_rider}) and
        #     (replace(lower(CONCAT_WS('', users.f_name, users.m_name, users.l_name)), ' ', '') like
        #     lower(replace('%#{search}%', ' ', '')) or replace(lower(vehicles.plate_number), ' ', '') LIKE
        #     replace('%#{search}%', ' ', '')) and trips.trip_type in (#{direction})")
      else
        start_date = filter_params['startDate']
        end_date = filter_params['endDate']
        # @count = Trip.count_by_sql("select count(distinct trips.id) from trips left join drivers on
        #     (trips.driver_id = drivers.id) left join vehicles on (trips.vehicle_id = vehicles.id) left join
        #     trip_routes on (trips.id = trip_routes.trip_id) left join employee_trips on
        #     (trip_routes.employee_trip_id = employee_trips.id) left join employees on
        #     (employee_trips.employee_id = employees.id) left join users on ((users.entity_id = drivers.id and
        #     users.entity_type = 'Driver') or ((users.entity_id = employees.id and users.entity_type =
        #     'Employee'))) where trips.status in (#{trip_status}) and trips.bus_rider in (#{bus_rider}) and
        #     (replace(lower(CONCAT_WS('', users.f_name, users.m_name, users.l_name)), ' ', '') like
        #     lower(replace('%#{search}%', ' ', '')) or replace(lower(vehicles.plate_number), ' ', '') LIKE
        #     replace('%#{search}%', ' ', '')) and trips.trip_type in (#{direction}) and employee_trips.date 
        #     between '#{start_date}' and '#{end_date}'")
        @count = Trip.includes(:vehicles, :trip_routes, [:employee_trips => [:employee => [:user]]], :driver => [:user])
            .where('trips.status' => trip_status, 
              'trips.bus_rider' => bus_rider, 
              'trips.trip_type' => direction,
              'employee_trips.date' => start_date..end_date)
            .where("(replace(lower(CONCAT_WS('', users.f_name, users.m_name, users.l_name)), ' ', '') like
                lower(replace('%#{search}%', ' ', '')) or replace(lower(vehicles.plate_number), ' ', '') LIKE
                replace('%#{search}%', ' ', ''))")
            .count
      end
    end

    @count
  end

  def get_trips
    @trips = []
    # TODO: mark trip as mised or smth
    if params['status'] == 'manifest_status'

      direction = filter_params['direction']
      bus_rider = filter_params['busRider']
      trip_status = filter_params['trip_status']
      start = params["start"]
      search = params['search'].delete(' ').downcase

      trip_status_set = filter_params['trip_status_set']

      if params['search'].blank?
        if filter_params["startDate"].blank? && filter_params["endDate"].blank?
          # @trip_ids = Trip.find_by_sql("select distinct trips.id, trips.status from trips 
          #   where trips.status in (#{trip_status}) and trips.bus_rider in (#{bus_rider}) and
          #   trips.trip_type in (#{direction}) order by find_in_set (trips.status,
          #   #{trip_status_set}) , id desc limit #{per_page} offset #{start}").to_a
          # trip_ids = []
          # @trip_ids.each do |ti|
          #   trip_ids.push(ti.id)
          # end
          # if trip_ids.present?
          #   @trips = Trip.where(id: trip_ids).order("field(id, #{trip_ids.join(',')})")
          # end
          @trips = Trip.includes(:vehicle, :trip_routes => [:employee_trip => [:employee]], :employee_trips => [:employee => [:user, :site]], :driver => [:user])
            .where('trips.status' => trip_status, 
            'trips.bus_rider' => bus_rider, 'trips.trip_type' => direction)
            .order("FIELD(trips.status, #{trip_status_set})").order('trips.id desc')
            .limit(per_page).offset(start)            
        else
          start_date = filter_params['startDate']
          end_date = filter_params['endDate']
          # @trip_ids = Trip.find_by_sql("select distinct trips.id, trips.status from trips 
          #   left join employee_trips on (trips.id = employee_trips.trip_id)  
          #   where trips.status in (#{trip_status}) and trips.bus_rider in (#{bus_rider}) 
          #   and trips.trip_type in (#{direction}) and employee_trips.date 
          #   between '#{start_date}' and '#{end_date}' order by find_in_set (trips.status,
          #   #{trip_status_set}) , id desc limit #{per_page} offset #{start}").to_a
          @trips = Trip.includes(:vehicle, :trip_routes => [:employee_trip => [:employee]], :employee_trips => [:employee => [:user, :site]], :driver => [:user])
            .where('trips.status' => trip_status, 
                    'trips.bus_rider' => bus_rider, 'trips.trip_type' => direction, 
                    'employee_trips.date' => start_date..end_date)
            .order("FIELD(trips.status, #{trip_status_set})").order('trips.id desc')
            .limit(per_page).offset(start)
        end        
      else
        if filter_params["startDate"].blank? && filter_params["endDate"].blank?
          # @trip_ids = Trip.find_by_sql("select distinct trips.id, trips.status from trips left join drivers on
          #   (trips.driver_id = drivers.id) left join vehicles on (trips.vehicle_id = vehicles.id) left join
          #   trip_routes on (trips.id = trip_routes.trip_id) left join employee_trips on
          #   (trip_routes.employee_trip_id = employee_trips.id) left join employees on
          #   (employee_trips.employee_id = employees.id) left join users on ((users.entity_id = drivers.id and
          #   users.entity_type = 'Driver') or ((users.entity_id = employees.id and users.entity_type =
          #   'Employee'))) where trips.status in (#{trip_status}) and trips.bus_rider in (#{bus_rider}) and
          #   (replace(lower(CONCAT_WS('', users.f_name, users.m_name, users.l_name)), ' ', '') like
          #   lower(replace('%#{search}%', ' ', '')) or replace(lower(vehicles.plate_number), ' ', '') LIKE
          #   replace('%#{search}%', ' ', '')) and trips.trip_type in (#{direction}) order by find_in_set (trips.status,
          #   #{trip_status_set}) , id desc limit #{per_page} offset #{start}").to_a
          # trip_ids = []
          # @trip_ids.each do |ti|
          #   trip_ids.push(ti.id)
          # end
          # if trip_ids.present?
          #   @trips = Trip.where(id: trip_ids).order("field(id, #{trip_ids.join(',')})")
          # end
          @trips = Trip.joins(:vehicle, :trip_routes => [:employee_trip => [:employee]], :employee_trips => [:employee => [:user, :site]], :driver => [:user])
            .includes(:vehicle, :trip_routes => [:employee_trip => [:employee]], :employee_trips => [:employee => [:user, :site]], :driver => [:user])
            .where('trips.status' => trip_status, 
              'trips.bus_rider' => bus_rider, 
              'trips.trip_type' => direction)
            .where("(replace(lower(CONCAT_WS('', users.f_name, users.m_name, users.l_name)), ' ', '') like
                lower(replace('%#{search}%', ' ', '')) or replace(lower(vehicles.plate_number), ' ', '') LIKE
                replace('%#{search}%', ' ', ''))")
            .order("FIELD(trips.status, #{trip_status_set})").order('trips.id desc')
            .limit(per_page).offset(start)            
        else
          start_date = filter_params['startDate']
          end_date = filter_params['endDate']
          @trips = Trip.joins(:vehicle, :trip_routes => [:employee_trip => [:employee]], :employee_trips => [:employee => [:user, :site]], :driver => [:user])
            .includes(:vehicle, :trip_routes => [:employee_trip => [:employee]], :employee_trips => [:employee => [:user, :site]], :driver => [:user])
            .where('trips.status' => trip_status, 
              'trips.bus_rider' => bus_rider, 
              'trips.trip_type' => direction,
              'employee_trips.date' => start_date..end_date)
            .where("(replace(lower(CONCAT_WS('', users.f_name, users.m_name, users.l_name)), ' ', '') like
                lower(replace('%#{search}%', ' ', '')) or replace(lower(vehicles.plate_number), ' ', '') LIKE
                replace('%#{search}%', ' ', ''))")
            .order("FIELD(trips.status, #{trip_status_set})").order('trips.id desc')
            .limit(per_page).offset(start)              
        end
      end  
      @trips
      # @trips = Trip.find_by_sql("select * from trips where trip_type=#{direction} and bus_rider=#{bus_rider} order by find_in_set(status,'created,assign_request_declined,accepted,assigned,assign_request_expired,assign_requested,active,completed,canceled') , id desc limit #{start}, #{per_page}")
      # @trips = unassigned_trips = Trip.where(:trip_type => filter_params['direction']).where(:bus_rider => filter_params['busRider']).where(:status => ['created', 'assign_request_declined']).order(id: :desc)
      # puts "-------------------"
      # @trips = []
      # if filter_params["startDate"].blank? && filter_params["endDate"].blank?
      #   unassigned_trips = Trip.where(:trip_type => filter_params['direction']).where(:bus_rider => filter_params['busRider']).where(:status => ['created', 'assign_request_declined']).order(id: :desc)
      #   assigned_trips = Trip.where(:trip_type => filter_params['direction']).where(:bus_rider => filter_params['busRider']).where(:status => ['accepted', 'assigned', 'assign_request_expired', 'assign_requested']).order(id: :desc)
      #   active_trips = Trip.where(:trip_type => filter_params['direction']).where(:bus_rider => filter_params['busRider']).where(:status => ['active']).order(id: :desc)
      #   completed_trips = Trip.where(:trip_type => filter_params['direction']).where(:bus_rider => filter_params['busRider']).where(:status => ['completed', 'canceled']).order(id: :desc)        
      #   @trips = unassigned_trips + assigned_trips + active_trips + completed_trips
      #   @trips
      # else
      #   unassigned_trips = Trip.eager_load(:employee_trips).where(:status => ['created', 'assign_request_declined']).where(:trip_type => filter_params['direction']).where('employee_trips.date' => filter_params['startDate']..filter_params['endDate']).where(:bus_rider => filter_params['busRider']).order(id: :desc)
      #   assigned_trips = Trip.eager_load(:employee_trips).where(:status => ['accepted', 'assigned', 'assign_request_expired', 'assign_requested']).where(:trip_type => filter_params['direction']).where(:bus_rider => filter_params['busRider']).where('employee_trips.date' => filter_params['startDate']..filter_params['endDate']).order(id: :desc)
      #   active_trips = Trip.eager_load(:employee_trips).where(:status => ['active']).where(:trip_type => filter_params['direction']).where(:bus_rider => filter_params['busRider']).where('employee_trips.date' => filter_params['startDate']..filter_params['endDate']).order(id: :desc)
      #   completed_trips = Trip.eager_load(:employee_trips).where(:status => ['completed', 'canceled']).where(:trip_type => filter_params['direction']).where(:bus_rider => filter_params['busRider']).where('employee_trips.date' => filter_params['startDate']..filter_params['endDate']).order(id: :desc)              
      #   @trips = unassigned_trips + assigned_trips + active_trips + completed_trips
      #   @trips        
      # end
    else
      @trips = Trip.where(:status => get_status).order(id: :desc).includes(:vehicle).includes(:driver).includes(employee_trips: [:employee, :trip_route])
    end
    # if params['status'] == ["created", "assign_request_expired", "assign_request_declined", "completed", "canceled"]
    #   @trips = Trip.where(:status => get_status).order(id: :desc)
    # elsif params['status'] == "completed"
    #   # In case of completed trips, show canceled with exception trips and completed trips
    #   @trips = Trip.where("status = 'completed' or (status = 'canceled' and cancel_status IS NOT NULL)").order(id: :desc)
    # elsif params['status'] == "canceled"
    #   # Do not show canceled with exception trips here
    #   # @trips = Trip.where(:status => get_status).where(:cancel_status => nil).order(id: :desc)
    #   @trips = Trip.where(:status => get_status).where(:cancel_status => nil).order(id: :desc)
    # else
    #   @trips = Trip.where(:status => get_status).order(id: :desc)
    # end
  end

  # get params from date filter
  def filter_params
    startDate = Time.zone.parse(params['startDate']).in_time_zone('UTC') unless params['startDate'].blank?
    endDate = Time.zone.parse(params['endDate']).in_time_zone('UTC') unless params['endDate'].blank?
    direction = params['direction'] == '2' ? [0, 1] : params['direction']
    trip_status = 'created'

    if params['trip_status'] == '0'
      trip_status = ['created']
      trip_status_set = "'created'"
    elsif params['trip_status'] == '1'
      trip_status = ['assign_requested','assign_request_expired','assign_request_declined']
      trip_status_set = "'assign_requested','assign_request_expired','assign_request_declined'"
    elsif params['trip_status'] == '2'
      trip_status = ['assigned']
      trip_status_set = "'assigned'"
    elsif params['trip_status'] == '3'
      trip_status = ['active']
      trip_status_set = "'active'"
    elsif params['trip_status'] == '4'
      trip_status = ['canceled']
      trip_status_set = "'canceled'"
    elsif params['trip_status'] == '5'
      trip_status = ['completed']
      trip_status_set = "'completed'"
    elsif params['trip_status'] == '6'
      trip_status = ['created','assign_request_declined','accepted','assigned','assign_request_expired','assign_requested','active','completed','canceled']
      trip_status_set = "'created','assign_request_declined','accepted','assigned','assign_request_expired','assign_requested','active','completed','canceled'"
    end

    if params['bus_rider'] == '2'
      busRider = [0,1]
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
        'trip_status' => trip_status,
        'trip_status_set' => trip_status_set,
        'search' => params['search']
    }
  end

  private
  def get_status
    given_statuses = ['created', 'assign_request_declined', 'accepted', 'assigned', 'assign_request_expired', 'assign_requested', 'active', 'completed', 'canceled']
    status = Array.wrap(params['status']) & given_statuses
  end

  def data
    trip_rosters.map do |trip|
      TripRosterDatatable.new(trip, @user).data
    end
  end

  def trip_rosters
    @trip ||= fetch_trip
  end

  def fetch_trip
    trip = get_trips
    # trip = Kaminari.paginate_array(trip).page(page).per(per_page)
    trip
  end

  def possible_sort_columns
    %w[id]
  end
end
