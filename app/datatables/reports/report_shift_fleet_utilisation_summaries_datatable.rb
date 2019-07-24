class Reports::ReportShiftFleetUtilisationSummariesDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view)
    @view = view
    @sort_column_names = {
      date: "date",
      shift_time: "shift_time",
      direction: "employee_trips.trip_type",
      vehicle_deployed: "",
      total_capacity: "",
      planned_capacity: "",
      actual_capacity: "",
      load_factor: ""
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
      get_trips.map { |data, trip| csv << Reports::ReportShiftFleetUtilisationSummaryDatatable.new(data, trip).data.values }
    end
  end

  private

  def data
    all_trips.map { |data, trip| Reports::ReportShiftFleetUtilisationSummaryDatatable.new(data, trip).data }
  end

  def all_trips
    Kaminari.paginate_array(get_trips).page(page).per(per_page)

  end

  def get_trips
    sort_val = @sort_column_names[get_sort_params.to_sym].present? ? @sort_column_names[get_sort_params.to_sym] : "date"
    Trip.completed
        .joins(:employee_trips)
        .joins("left outer join vehicles on vehicles.id = trips.vehicle_id")
        .select("trips.id,DATE(convert_tz(employee_trips.date,'-05:30', '+00:00')) as date,DATE_FORMAT(convert_tz(employee_trips.date,'-05:30', '+00:00'), '%H:%i') as shift_time,employee_trips.date as employee_trip_date,vehicles.seats as seats,employee_trips.status,employee_trips.trip_type")
        .where("employee_trips.date BETWEEN '#{filter_params.symbolize_keys[:startDate]}' AND '#{filter_params.symbolize_keys[:endDate]}'")
        .order("#{sort_val} #{sort_direction}")
        .group_by { |x| [x.date, x.shift_time, x.trip_type] }.to_a
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
