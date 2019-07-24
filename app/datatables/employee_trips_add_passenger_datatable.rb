class EmployeeTripsAddPassengerDatatable
  def initialize(trip = nil)
    @trip = trip
  end

  def as_json(options = {})
    {
        :data => data
    }
  end

  def data
    if @trip.bus_rider
      status = "#{@trip.status.humanize} - Nodal"
    else
      status = "#{@trip.status.humanize} - D2D"
    end
    

    {
       "DT_RowId" => "#{EmployeeTrip::DATATABLE_PREFIX}-#{@trip.id}",
       :employee_name => @trip.employee.user.f_name,
       :employee_l_name => @trip.employee.user.l_name,
       :phone => @trip.employee.user.phone,
       :sex => @trip.employee.gender.to_s.first.capitalize,
       :status => status,
       :date => @trip.date.strftime("%m/%d/%Y %H:%M"),
       :site => @trip.employee.site.name,
       :geohash => @trip.employee.geohash,
       :eta => @trip.eta,
       :id => @trip.id,
       :employee_id => @trip.employee.employee_id,
       :message => "Message",
       :employee_cluster_id => @trip.employee_cluster_id,
       :area => @trip.employee.landmark || '--'
    }
  end
end
