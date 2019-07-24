class Reports::ReportTripWiseDriverExceptionsDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view)
    @view = view
    @sort_column_names = {
      date: "date",
      trip_id: "trips.id",
      shift_time: "shift_time",
      direction: "employee_trips.trip_type",
      driver_name: "driver_name",
      plate_number: "vehicles.plate_number",
      out_of_geofence_driver_arrived: "",
      out_of_geofence_pick_up: "",
      out_of_geofence_drop_off: "",
      panic_alert: "",
      car_broke_down: ""
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
      get_trips.map { |trip| csv << Reports::ReportTripWiseDriverExceptionDatatable.new(trip).data.values }
    end
  end

  private

  def data
    all_trips.map { |trip| Reports::ReportTripWiseDriverExceptionDatatable.new(trip).data }
  end

  def all_trips
    @trip ||= get_trips.page(page).per(per_page)

  end

  def get_trips
    sort_val = @sort_column_names[get_sort_params.to_sym].present? ? @sort_column_names[get_sort_params.to_sym] : "date"
    Trip.joins(:employee_trips)
        .joins("left outer join vehicles on vehicles.id = trips.vehicle_id")
        .joins("left outer join drivers ON drivers.id = trips.driver_id")
        .joins("left outer join users on users.entity_id = drivers.id and users.entity_type = 'Driver'")
        .select("trips.id,DATE(convert_tz(employee_trips.date,'-05:30', '+00:00')) as date,DATE_FORMAT(convert_tz(employee_trips.date,'-05:30', '+00:00'), '%H:%i') as shift_time,vehicles.plate_number,CONCAT('', users.f_name,users.m_name,users.l_name) AS driver_name,employee_trips.trip_type")
        .where("employee_trips.date BETWEEN '#{filter_params.symbolize_keys[:startDate]}' AND '#{filter_params.symbolize_keys[:endDate]}' and trips.driver_id is not null")
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
