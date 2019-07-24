class Reports::ReportTripLogsDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view, trips = nil)
    @view = view
    @trips = trips
    @sort_column_names = {
      date: "",
      trip_id: "trips.id",
      driver: "users.f_name",
      operator: "",
      plate_number: "vehicles.plate_number",
      shift_time: "",
      direction: "",
      actual_time: "",
      trip_created: "",
      trip_assigned: "",
      trip_accepted: "trips.trip_accept_time",
      trip_started: "trips.start_date",
      number_of_riders: "",
      distance: "trips.scheduled_approximate_distance",
      duration: "trips.scheduled_approximate_duration",
      status: "",
      exception_detail: "trips.cancel_status",
      vehicle_capacity: "vehicles.seats",
      delta_time: ""
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
      get_trips.map { |trip| csv << Reports::ReportTripLogDatatable.new(trip).data.values }
    end
  end

  private

  def data
    all_trips.map { |trip| Reports::ReportTripLogDatatable.new(trip).data }
  end

  def all_trips
    @trip ||= get_trips.page(page).per(per_page)
  end

  def get_trips
    sort_val = @sort_column_names[get_sort_params.to_sym].present? ? @sort_column_names[get_sort_params.to_sym] : "trips.id"
    Trip.joins(:trip_routes, :employee_trips)
        .joins("left outer join drivers ON drivers.id = trips.driver_id")
        .joins("left outer join users on users.entity_id = drivers.id and users.entity_type = 'Driver'")
        .joins("left outer join vehicles on vehicles.id = trips.vehicle_id")
        .where("employee_trips.date BETWEEN '#{filter_params.symbolize_keys[:startDate]}' AND '#{filter_params.symbolize_keys[:endDate]}'")
        .select("trips.id,
                 DATE(convert_tz(employee_trips.date,'-05:30', '+00:00')) as date,
                 CONCAT_WS(' ',users.f_name,users.m_name,users.l_name) AS driver_full_name,
                 DATE_FORMAT(convert_tz(employee_trips.date,'-05:30', '+00:00'), '%H:%i') as shift_time,
                 employee_trips.trip_type,
                 trips.completed_date,
                 trips.trip_accept_time,
                 trips.start_date,
                 trips.scheduled_approximate_distance,
                 trips.real_duration,
                 trips.cancel_status,
                 trips.status,
                 trips.completed_date,
                 vehicles.seats,
                 vehicles.plate_number,
                 users.entity_id as driver_id,
                 trips.trip_assign_date,
                 trips.created_at
                 ")
        .order("#{sort_val} #{sort_direction}")
        .distinct
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
