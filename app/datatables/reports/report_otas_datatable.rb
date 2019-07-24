class Reports::ReportOtasDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view)
    @view = view
    @sort_column_names = {
      date: "date",
      trip_id: "trips.id",
      status: "trips.status",
      driver: "driver_name",
      vehicle: "vehicle_no",
      ba: "ba",
      shift_time: "trips.id",
      scheduled_end_time: "trips.id",
      actual_end_time: "trips.completed_date",
      delta_in_arrival_at_site: "trips.id",
      planned_first_pickup_time: "trips.planned_date",
      actual_arrival_time_for_first_pickup: "trips.id",
      actual_first_pickup_time: "trips.id"
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
      get_trips.each { |trip| csv << Reports::ReportOtaDatatable.new(trip).data.values }
    end
  end

  private

  def data
    all_trips.map { |trip| Reports::ReportOtaDatatable.new(trip).data }
  end

  def all_trips
    @trip ||= get_trips.page(page).per(per_page)
  end

  def get_trips
    sort_val = @sort_column_names[get_sort_params.to_sym].present? ? @sort_column_names[get_sort_params.to_sym] : "trips.id"
    # Trip.completed
      Trip.joins(:trip_routes, :employee_trips)
        .joins("left outer join vehicles on vehicles.id = trips.vehicle_id")
        .joins("left outer join drivers ON drivers.id = trips.driver_id")
        .joins("left outer join logistics_companies on logistics_companies.id=drivers.logistics_company_id")
        .joins("left outer join users on users.entity_id = drivers.id and users.entity_type = 'Driver'")
        .select("trips.id,trips.planned_date,trips.planned_approximate_duration,trips.completed_date,DATE(employee_trips.schedule_date) as date,users.f_name as driver_name,vehicles.plate_number as vehicle_no,logistics_companies.name as ba,employee_trips.date as employee_trip_date,trips.scheduled_date,trips.status")
        .where("employee_trips.date BETWEEN '#{filter_params.symbolize_keys[:startDate]}' AND '#{filter_params.symbolize_keys[:endDate]}' and employee_trips.trip_type='0' and employee_trips.status in ('completed','canceled')")
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
