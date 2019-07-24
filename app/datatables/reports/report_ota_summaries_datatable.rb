class Reports::ReportOtaSummariesDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view, trips = nil)
    @view = view
    @trips = trips
    @sort_column_names = {
      date: "",
      shift_time: "",
      total_logins: "",
      logins_catered_to: "",
      logins_canceled: "",
      logins_delayed: "",
      avg_delay_to_login: ""
    }
  end

  def as_json(options = {})
    count = get_trips.count
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
      all_trips.each { |date, trips| csv << Reports::ReportOtaSummaryDatatable.new(date, trips).data.values }
    end
  end

  private

  def data
    all_trips.map do |date, trips|
      Reports::ReportOtaSummaryDatatable.new(date, trips).data
    end
  end

  def all_trips
    @trip ||= get_trips
  end

  def fetch_trip
    trip = get_trips.order("#{sort_column} #{sort_direction}")
    trip = trip.page(page).per(per_page)
    trip
  end

  def possible_sort_columns
    %w[id]
  end

  def get_trips
    Trip.joins(:trip_routes, :employee_trips, :vehicle, :driver)
        .select("trips.id,DATE(convert_tz(employee_trips.date,'-05:30', '+00:00')) as date,trips.status,DATE_FORMAT(convert_tz(employee_trips.date,'-05:30', '+00:00'), '%H:%i') as shift_time,trips.completed_date,trips.scheduled_date,trips.scheduled_approximate_duration,employee_trips.date as employee_trip_date,trips.cancel_status")
        .where("employee_trips.date BETWEEN '#{filter_params.symbolize_keys[:startDate]}' AND '#{filter_params.symbolize_keys[:endDate]}' AND trips.status in ('canceled', 'completed')")
        .where(trip_type: :check_in)
        .distinct
        .group_by { |x| [x.date, x.shift_time] }
  end

  # get data from filter
  def filter_params
    today = Time.zone.now.beginning_of_day.in_time_zone('UTC')
    startdate = params['startDate'].blank? ? (today - 1.month) : Time.zone.parse(params['startDate']).in_time_zone('UTC')
    endDate = params['endDate'].blank? ? today : Time.zone.parse(params['endDate']).in_time_zone('UTC')
    {
        'startDate' => startdate,
        'endDate'=> endDate
    }
  end

end
