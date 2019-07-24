class Reports::ReportOtdsDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view)
    @view = view
    @sort_column_names = {
        date: "date",
        trip_id: "trips.id",
        status: "trips.status",
        driver_name: "driver_name",
        vehicle: "vehicle_no",
        vendor_name: "vendor_name",
        shift_time: "trips.id",
        driver_arrival_at_site: "trips.id",
        scheduled_depature_time: "trips.id",
        actual_depature_time: "trips.id"
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
      get_trips.map { |trip| csv << Reports::ReportOtdDatatable.new(trip).data.values }
    end
  end

  private

  def data
    all_trips.map { |trip| Reports::ReportOtdDatatable.new(trip).data }
  end

  def all_trips
    @trip ||= get_trips.page(page).per(per_page)
  end

  def get_trips
    sort_val = @sort_column_names[get_sort_params.to_sym].present? ? @sort_column_names[get_sort_params.to_sym] : "trips.id"
    Trip.joins(:trip_routes, :employee_trips)
        .joins("left outer join drivers ON drivers.id = trips.driver_id")
        .joins("left outer join users on users.entity_id = drivers.id and users.entity_type = 'Driver'")
        .joins("left outer join logistics_companies on logistics_companies.id = drivers.logistics_company_id")
        .joins("left outer join vehicles on vehicles.id = trips.vehicle_id")
        .select("trips.id,trips.planned_date,trips.planned_approximate_duration,trips.completed_date,trips.scheduled_date,DATE(employee_trips.date) as date,vehicles.plate_number as vehicle_no,DATE_FORMAT(employee_trips.date, '%H:%i') as shift_time,logistics_companies.name as vendor_name,trips.status,CONCAT_WS('',users.f_name,users.l_name) AS driver_name")
        .where("employee_trips.date BETWEEN '#{filter_params.symbolize_keys[:startDate]}' AND '#{filter_params.symbolize_keys[:endDate]}' and employee_trips.trip_type='1' and employee_trips.status in ('completed','canceled')")
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