class DriverRequestsDatatable
  include DatatablePagination

  delegate :params, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    count = get_requests.count
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data
    }
  end

  def get_requests
    DriverRequest.where(:request_state => ['pending', 'cancel']).order(id: :desc)
  end

  private

  def data
    trip_request.map do |request|
      DriverRequestDatatable.new(request).data
    end
  end

  def trip_request
    @request ||= fetch_request
  end

  def fetch_request
    request = get_requests
    request = request.page(page).per(per_page)
    request
  end

  def possible_sort_columns
    %w[id]
  end
end
