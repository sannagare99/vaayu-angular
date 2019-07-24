class Reports::ReportUtilizationsDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view)
    @view = view
  end

  # TODO: DO this!!!
  def as_json(options = {})
    count = get_trip_groups.count
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data
    }
  end

  private
  # get trips for reports
  def get_trip_groups
    Trip.joins(:vehicle, :trip_routes)
        .where(:status => 'completed')
        .where(:start_date => filter_params['startDate']..filter_params['endDate'])
        .group_by(&:scheduled_data)
  end

  def data
    all_trips.map do |trip|
      Reports::ReportUtilizationDatatable.new(trip).data
    end
  end

  def all_trips
    @trip_group ||= fetch_trip
  end

  def fetch_trip
    trip = get_trip_groups
  end

  def possible_sort_columns
    %w[id]
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
