class BusTripDatatable
  def initialize(bus_trip = nil)
    @bus_trip = bus_trip
  end

  def as_json(options = {})
    {
        :data => data
    }
  end

  def data
    {
       "DT_RowId" => "#{BusTrip::DATATABLE_PREFIX}-#{@bus_trip.id}",
       :id => @bus_trip.id,
       :route_name => @bus_trip.route_name,
       :stops => @bus_trip.bus_trip_routes.size,
       :start => @bus_trip.bus_trip_routes&.first&.stop_name,
       :end => @bus_trip.bus_trip_routes&.last&.stop_name,
       :status => @bus_trip.status.humanize
    }
  end
end
