class Reports::ReportActiveTripsDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    count = Trip.where(:status => 'active').count
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
      Reports::ReportActiveTripDatatable.new(trip).data
    end
  end

  def all_trips
    @trip ||= fetch_trip
  end

  def fetch_trip
    trip = Trip.where(:status => 'active').order("#{sort_column} #{sort_direction}")
    trip = trip.page(page).per(per_page)
    trip
  end

  def possible_sort_columns
    %w[id]
  end
end
