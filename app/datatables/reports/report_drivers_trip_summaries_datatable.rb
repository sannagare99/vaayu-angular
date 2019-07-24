class Reports::ReportDriversTripSummariesDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view)
    @view = view
    @sort_column_names = {
      date: "trip_date",
      driver_name: "driver_name",
      vehicle: "vehicles.plate_number",
      total_trips: "",
      mileage: "",
      mileage_per_trip: ""
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
      get_trips.map { |group_info,trip| csv << Reports::ReportDriversTripSummaryDatatable.new(group_info, trip).data.values }
    end
  end

  private

  def data
    all_trips.map { |group_info, trip| Reports::ReportDriversTripSummaryDatatable.new(group_info, trip).data }
  end

  def all_trips
    Kaminari.paginate_array(get_trips).page(page).per(per_page)

  end

  def get_trips
    sort_val = @sort_column_names[get_sort_params.to_sym].present? ? @sort_column_names[get_sort_params.to_sym] : "date"
    Trip.completed
        .joins(:vehicle, :employee_trips)
        .joins("left outer join drivers ON drivers.id = trips.driver_id")
        .joins("left outer join users on users.entity_id = drivers.id and users.entity_type = 'Driver'")
        .select("DATE(convert_tz(employee_trips.date,'-05:30', '+00:00')) as trip_date,CONCAT('', users.f_name,users.m_name,users.l_name) AS driver_name,vehicles.plate_number,trips.id,trips.scheduled_approximate_distance")
        .where("employee_trips.date BETWEEN '#{filter_params.symbolize_keys[:startDate]}' AND '#{filter_params.symbolize_keys[:endDate]}'")
        .distinct
        .order("#{sort_val} #{sort_direction}")
        .group_by { |x| [x.trip_date, x.driver_name, x.plate_number] }.to_a
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
