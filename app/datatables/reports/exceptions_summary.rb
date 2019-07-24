class Reports::ExceptionsSummary
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    count = fetch_trip.count
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data
    }
  end

  def fetch_trip
     Trip.where(:scheduled_date => filter_params['startDate']..filter_params['endDate']).group_by(&:scheduled_data)
   end

  private
  def data
    all_trips.map do |trip|
      Reports::ExceptionSummary.new(trip).data
    end
  end

  def all_trips
    @trips ||= fetch_trip
  end

  # def fetch_trip
  #   trip = get_trips
  #   trip
  # end

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
