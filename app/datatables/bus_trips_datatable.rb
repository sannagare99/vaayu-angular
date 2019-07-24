class BusTripsDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    count = BusTrip.count
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data
    }
  end

  private

  def data
    bus_trips.map do |bus_trip|
      BusTripDatatable.new(bus_trip).data
    end
  end

  def bus_trips
    @bus_trips ||= fetch_bus_trips
  end

  def fetch_bus_trips
    bus_trip = BusTrip.order("#{sort_column} #{sort_direction}")
    bus_trip = bus_trip.page(page).per(per_page)
    bus_trip
  end

  def possible_sort_columns
    %w[id name]
  end
end
