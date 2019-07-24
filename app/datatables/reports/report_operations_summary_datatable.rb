class Reports::ReportOperationsSummaryDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view, trips = nil)
    @view = view
    @trips = trips
    @sort_column_names = {
      date: "date",
      total_trips: "date",
      trips_catered_to: "date",
      trips_canceled: "date",
      drivers: "date",
      total_distance: "date",
      distance_per_trip: "date",
      duration_per_trip: "date"
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
      all_trips.each { |date, trips| csv << Reports::ReportOperationSummaryDatatable.new(date, trips).data.values }
    end
  end

  private

  def data
    all_trips.map do |date, trips|
      Reports::ReportOperationSummaryDatatable.new(date, trips).data
    end
  end

  def all_trips
    @trip ||= get_trips#.page(page).per(per_page)
  end

  def possible_sort_columns
    %w[id]
  end

  def get_trips
    sort_val = @sort_column_names[get_sort_params.to_sym].present? ? @sort_column_names[get_sort_params.to_sym] : "trips.id"
    Trip.joins(:employee_trips)
        .select("trips.id,DATE(convert_tz(employee_trips.date,'-05:30', '+00:00')) as date,trips.status,trips.driver_id,trips.scheduled_approximate_distance,trips.real_duration,trips.cancel_status")
        .where("employee_trips.date BETWEEN '#{filter_params.symbolize_keys[:startDate]}' AND '#{filter_params.symbolize_keys[:endDate]}'")
        .distinct
        .group_by(&:date)
        # .order("#{sort_column} #{sort_direction}")
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
