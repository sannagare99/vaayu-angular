class Reports::ReportPanicAlarmsDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view, trips = nil)
    @view = view
    @trips = trips
    @sort_column_names = {
      date: "",
      manifest_id: "",
      driver: "",
      vehicle: "",
      employee_id: "",
      alarm_time: "",
      location: "",
      resolution_time: "",
      resolved_by: ""
    }
  end

  def as_json(options = {})
    count = get_exceptions.count
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
      get_exceptions.each { |exception| csv << Reports::ReportPanicAlarmDatatable.new(exception).data.values }
    end
  end


  private

  def data
    all_exceptions.map do |exception|
      Reports::ReportPanicAlarmDatatable.new(exception).data
    end
  end

  def all_exceptions
    @exceptions ||= get_exceptions
  end

  def fetch_exceptions
    exception = get_exceptions.order("#{sort_column} #{sort_direction}")
    exception = exception.page(page).per(per_page)
    exception
  end

  def possible_sort_columns
    %w[id]
  end

  def get_exceptions
    TripRouteException.where(:exception_type => :panic).where(:date => filter_params['startDate']..filter_params['endDate'])
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
