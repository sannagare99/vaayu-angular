class Reports::ReportEmployeeLogsDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view, trips = nil)
    @view = view
    @trips = trips
    @sort_column_names = {
      date:  "date",
      trip_id: "trips.id",
      driver: "",
      operator: "",
      plate_number: "",
      status: "",
      shift_time: "shift_time",
      direction: "",
      employee_id: "",
      rider_name: "",
      notified_eta: "",
      i_am_here: "",
      pick_up_time: "",
      drop_off_time: "",
      employee_status: "",
      exception_detail: "",
      planned_eta: "",
      wait_time: ""
    }
  end

  def as_json(options = {})
    count = get_trips.length
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data
    }
  end

  def csv
    CSV.generate do |csv|
      csv << @sort_column_names.keys.map{ |x| x.to_s.camelize.to_sym }
      get_trips.map { |trip| csv << Reports::ReportEmployeeLogDatatable.new(trip).data.values }
    end
  end

  private

  def data
    all_trips.map { |trip| Reports::ReportEmployeeLogDatatable.new(trip).data }
  end

  def all_trips
    @trip ||= get_trips.page(page).per(per_page)
  end

  def possible_sort_columns
    %w[id]
  end

  def get_trips
    sort_val = @sort_column_names[get_sort_params.to_sym].present? ? @sort_column_names[get_sort_params.to_sym] : "trips.id"
    TripRoute.joins(:trip, :employee_trip)
             .joins("left outer join employees ON employees.id = employee_trips.employee_id")
             .joins("left outer join users on users.entity_id = employees.id and users.entity_type = 'Employee'")
             .where("employee_trips.date BETWEEN '#{filter_params.symbolize_keys[:startDate]}' AND '#{filter_params.symbolize_keys[:endDate]}'")
             .select("trip_routes.id,
                      trip_routes.trip_id,
                      DATE(convert_tz(employee_trips.date,'-05:30', '+00:00')) as date,
                      CONCAT_WS(' ',users.f_name,users.m_name,users.l_name) AS employee_name,
                      DATE_FORMAT(convert_tz(employee_trips.date,'-05:30', '+00:00'), '%H:%i') as shift_time,
                      employees.employee_id as employee_id,
                      employee_trips.trip_type,
                      trips.status as trips_status,
                      trips.cancel_status as trip_cancel_status,
                      trip_routes.on_board_date,
                      trip_routes.completed_date,
                      trip_routes.status,
                      trip_routes.cancel_exception,
                      trip_routes.driver_arrived_date,
                      trip_routes.bus_rider,
                      trips.scheduled_date,
                      trip_routes.on_board_date,
                      trip_routes.completed_date,
                      trip_routes.scheduled_route_order,
                      trips.planned_date")
            .order("#{sort_val} #{sort_direction}")
  end

  # get data from filter
  def filter_params
    today = Time.zone.now.beginning_of_day.in_time_zone('UTC')
    startdate = params['startDate'].blank? ? (today - 1.month) : Time.zone.parse(params['startDate'] + " IST").in_time_zone('UTC')
    endDate = params['endDate'].blank? ? today : Time.zone.parse(params['endDate'] + " IST").in_time_zone('UTC')
    {
        'startDate' => startdate,
        'endDate'=> endDate
    }
  end

end
