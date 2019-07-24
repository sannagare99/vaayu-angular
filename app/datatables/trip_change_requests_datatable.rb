class TripChangeRequestsDatatable
  include DatatablePagination

  delegate :params, to: :@view

  def initialize(view, current_user)
    @view = view
    @query_type = 'all'
    @user = current_user
  end

  def as_json(options = {})
    count = get_requests.count
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data
    }
  end

  def get_requests
    puts "--------------"
    puts filter_params    
    puts "--------------"
    line_manager_query = nil
    if @user.line_manager?
      line_manager_query = 'employees.line_manager_id = ' + @user&.entity_id&.to_s
    end

    puts line_manager_query
    name = params[:search].split(' ')
    if name[0].present? && name[1].present?
      name_query = 'users.f_name like "%' + name[0] + '%" and users.l_name like "%' + name[1] + '%"'
    else
      name_query = 'users.f_name like "%' + params[:search] + '%" or users.l_name like "%' + params[:search] + '%"'
    end
    order = "field(request_state, 'created', 'approved', 'declined')"

    if filter_params['type'] == "2"
      start_date_query = '`trip_change_requests`.`new_date` > ?'
      end_date_query = '`trip_change_requests`.`new_date` < ?'
      @query_type = 'new'
    elsif filter_params['type'] == "1"
      start_date_query = '`employee_trips`.`date` > ?'
      end_date_query = '`employee_trips`.`date` < ?'
      @query_type = 'cancel'
    elsif filter_params['type'] == "0"
      start_date_query = '`trip_change_requests`.`new_date` > ?'
      end_date_query = '`trip_change_requests`.`new_date` < ?'
      @query_type = 'change'
    end

    if @query_type == 'all'
      new_trip_request_created = TripChangeRequest.joins(:employee => [:zone, :user])
          .includes(:employee => [:zone, :site, :user])
          .where(name_query)
          .where(line_manager_query)
          .where(:request_type => :new_trip)
          .where(:request_state => 'created')
          .where(:new_date => filter_params['startDate']..filter_params['endDate'])
          .where(:trip_type => filter_params['trip_type'])

      change_trip_request_created = TripChangeRequest.joins(:employee_trip, :employee => [:zone, :user])
          .includes(:employee => [:zone, :site, :user])
          .where(name_query)
          .where(line_manager_query)
          .where(:request_type => :change)
          .where(:request_state => 'created')
          .where(:new_date => filter_params['startDate']..filter_params['endDate'])
          .where('employee_trips.trip_type' => filter_params['trip_type'])

      cancel_trip_request_created = TripChangeRequest.joins(:employee_trip, :employee => [:zone, :user])
          .includes(:employee => [:zone, :site, :user])
          .where(name_query)
          .where(line_manager_query)
          .where(:request_type => :cancel)
          .where(:request_state => 'created')
          .where('employee_trips.date > ?', filter_params['startDate'])
          .where('employee_trips.date < ?', filter_params['endDate'])
          .where('employee_trips.trip_type' => filter_params['trip_type'])      

      trip_request_created = new_trip_request_created + change_trip_request_created + cancel_trip_request_created

      trip_request_created = sort_trips(trip_request_created)

      new_trip_request_actioned = TripChangeRequest.joins(:employee => [:zone, :user])
          .includes(:employee => [:zone, :site, :user])
          .where(name_query)
          .where(line_manager_query)
          .where(:request_type => :new_trip)
          .where(:request_state => ['declined', 'approved'])
          .where(:new_date => filter_params['startDate']..filter_params['endDate'])
          .where(:trip_type => filter_params['trip_type'])

      change_trip_request_actioned = TripChangeRequest.joins(:employee_trip, :employee => [:zone, :user])
          .includes(:employee => [:zone, :site, :user])
          .where(name_query)
          .where(line_manager_query)
          .where(:request_type => :change)
          .where(:request_state => ['declined', 'approved'])
          .where(:new_date => filter_params['startDate']..filter_params['endDate'])
          .where('employee_trips.trip_type' => filter_params['trip_type'])

      cancel_trip_request_actioned = TripChangeRequest.joins(:employee_trip, :employee => [:zone, :user])
          .includes(:employee => [:zone, :site, :user])
          .where(name_query)
          .where(line_manager_query)
          .where(:request_type => :cancel)
          .where(:request_state => ['declined', 'approved'])
          .where('employee_trips.date > ?', filter_params['startDate'])
          .where('employee_trips.date < ?', filter_params['endDate'])
          .where('employee_trips.trip_type' => filter_params['trip_type'])      

      trip_request_actioned = new_trip_request_actioned + change_trip_request_actioned + cancel_trip_request_actioned
      trip_request_actioned = sort_trips(trip_request_actioned)
      

      trip_request = trip_request_created + trip_request_actioned

    else
      if @query_type == 'new'
        trip_request = TripChangeRequest.joins(:employee => [:zone, :user])
          .includes(:employee => [:zone, :site, :user])
          .where(name_query)
          .where(line_manager_query)
          .where(:request_type => :new_trip)          
          .where(:new_date => filter_params['startDate']..filter_params['endDate'])
          .where(:trip_type => filter_params['trip_type'])
          .order(order)
          .order('trip_change_requests.new_date ASC, zones.name DESC')
      else
        trip_request = TripChangeRequest.joins(:employee_trip, :employee => [:zone, :user])
          .includes(:employee => [:zone, :site, :user])
          .where(name_query)
          .where(line_manager_query)
          .where(:request_type => filter_params['type'])
          .where(start_date_query, filter_params['startDate'])
          .where(end_date_query, filter_params['endDate'])
          .where('employee_trips.trip_type' => filter_params['trip_type'])
          .order(order)
          .order('employee_trips.date ASC, zones.name DESC')      
      end      
    end    
  end

  private

  def sort_trips(trip_request)
    trip_request.sort do |a,b| 
        date1 = ""
        date2 = ""
        if a.request_type == 'cancel'
          date1 = a.employee_trip.date
        else
          date1 = a.new_date
        end

        if b.request_type == 'cancel'
          date2 = b.employee_trip.date
        else
          date2 = b.new_date
        end      
        date1 <=> date2
      end
    trip_request
  end

  def data
    trip_request.map do |request|
      TripChangeRequestDatatable.new(request).data
    end
  end

  def trip_request
    @request ||= fetch_request
  end

  def fetch_request
    request = get_requests
    if @query_type == 'all'
      request = Kaminari.paginate_array(request)
    end
    request = request.page(page).per(per_page)
    request
  end

  def possible_sort_columns
    %w[id]
  end

  def filter_params
    if params[:startDate].blank?
      startDate = Time.at(0)
    else
      startDate = Time.zone.parse(params[:startDate]).in_time_zone('UTC')
    end
    if params[:endDate].blank?
      endDate = Time.now.end_of_day
    else
      endDate = Time.zone.parse(params[:endDate]).in_time_zone('UTC')
    end

    direction = params[:direction] == '2' ? [0, 1] : params[:direction]
    type = params[:type] == '3' ? [0, 1, 2] : params[:type]

    
    {
        'startDate' => startDate,
        'endDate'=> endDate,
        'trip_type' => direction,
        'type' => type
    }
  end
end
