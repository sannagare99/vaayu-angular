class DriverRequestDatatable
  def initialize(request = nil)
    @request = request
  end

  def as_json(options = {})
    {
        :data => data
    }
  end

  def data
    {
       "DT_RowId" => "#{DriverRequest::DATATABLE_PREFIX}-#{@request.id}",
       :request_date => request_date,
       :status => @request.request_state.humanize,
       :driver_name => @request.driver_name,
       :driver_phone => @request.driver_phone,
       :reason => @request.reason&.humanize,
       :start_date => start_date,
       :end_date => end_date,
       :id => @request.id,
       :type => @request.request_type&.humanize,
    }
  end

  def start_date
    if @request.start_date.blank?
      ''
    else
      @request.start_date&.strftime("%m/%d/%Y %H:%M")
    end
  end

  def end_date
    if @request.end_date.blank?
      ''
    else
      @request.end_date&.strftime("%m/%d/%Y %H:%M")
    end
  end

  def request_date
    if @request.request_date.blank?
      ''
    else
      @request.request_date&.strftime("%m/%d/%Y %H:%M")
    end
  end

end
