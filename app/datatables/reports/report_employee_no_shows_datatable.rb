class Reports::ReportEmployeeNoShowsDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view)
    @view = view
    @sort_column_names = {
      date: "date",
      trip_id: "trip_id",
      status: "trip_status",
      direction: "direction",
      shift_time: "shift_time",
      driver: "driver_name",
      vehicle: "vehicle_no",
      employee_id: "employee_id",
      employee_name: "employee_name",
      gender: "gender",
      employee_pick_up_location: "pick_up_location_time",
      no_show_triggered_location: "no_show_triggered_location",
      no_show_trigger_time: ""
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
      get_trips.map { |trip| csv << Reports::ReportEmployeeNoShowDatatable.new(trip).data.values }
    end
  end

  private

  def data
    all_trips.map { |trip| Reports::ReportEmployeeNoShowDatatable.new(trip).data }
  end

  def all_trips
    @trip ||= get_trips.page(page).per(per_page)
  end

  def get_trips
    sort_val = @sort_column_names[get_sort_params.to_sym].present? ? @sort_column_names[get_sort_params.to_sym] : "date"

    TripRoute.joins(trip: [:vehicle, :driver], employee_trip: :employee)
             .joins("left outer join users on users.entity_id = employees.id and users.entity_type = 'Employee'")
             .joins("left outer join users as driver_users on driver_users.entity_id = drivers.id and driver_users.entity_type = 'Driver'")
             .select("
                trip_routes.id,
                DATE(employee_trips.date) as date,
                trips.id as trip_id,
                employee_trips.trip_type as direction,
                DATE_FORMAT(employee_trips.date, '%H:%i') as shift_time,
                employees.employee_id as employee_id,
                CONCAT_WS('',users.f_name,users.m_name,users.l_name) AS employee_name,
                employees.gender as gender,
                vehicles.plate_number as vehicle_no,
                trip_routes.planned_start_location,
                trip_routes.driver_arrived_location,
                trip_routes.missed_date,
                trips.status as trip_status,
                CONCAT_WS('', driver_users.f_name,driver_users.m_name,driver_users.l_name) AS driver_name")
             .where("employee_trips.date BETWEEN '#{filter_params.symbolize_keys[:startDate]}' AND '#{filter_params.symbolize_keys[:endDate]}' and trip_routes.status='missed'")
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
