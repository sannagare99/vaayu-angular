class TripChangeRequestDatatable
  def initialize(request = nil)
    @request = request
  end

  def as_json(options = {})
    {
        :data => data
    }
  end

  def data
    if @request.request_type == 'new_trip'
      trip_type = @request&.trip_type.humanize
    else
      trip_type = @request&.employee_trip&.trip_type.humanize
    end
     zone_result = @request.employee.zone.present? ? @request.employee.zone.name : ''
    {
       "DT_RowId" => "#{TripChangeRequest::DATATABLE_PREFIX}-#{@request.id}",
       :request_type => @request.request_type.humanize,
       :request_state => @request.request_state.humanize,
       :original_date => @request.employee_trip&.date&.strftime("%m/%d/%Y %H:%M"),
       :date => @request.new_date&.strftime("%H:%M"),
       :new_date => @request.new_date&.strftime("%m/%d/%Y %H:%M"),
       :trip_type => trip_type,
       :id => @request.id,
       :employee_id => @request.employee.employee_id,
       :employee_name => @request.employee.f_name,
       :employee_l_name => @request.employee.l_name,
       :gender => @request.employee.gender.to_s.first.capitalize,
       :reason => @request.reason&.humanize,
       :phone => @request.employee.phone,
       :zone => zone_result,
       :trip_status => @request.employee_trip&.trip&.status,
       :site_name => @request.employee&.site&.name
    }.merge(@request.employee.pick_up_lat_lng)
  end
end
