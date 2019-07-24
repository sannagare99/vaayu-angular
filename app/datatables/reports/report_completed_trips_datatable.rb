class Reports::ReportCompletedTripsDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view, trips = nil)
    @view = view
    @trips = trips
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

  private

  def data
    all_trips.map do |trip|
      Reports::ReportCompletedTripDatatable.new(trip).data
    end
  end

  def all_trips
    @trip ||= fetch_trip
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
    Trip.where(:status => 'completed').where(:start_date => filter_params['startDate']..filter_params['endDate'])
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
