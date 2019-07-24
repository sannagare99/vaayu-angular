class Reports::ReportEmployeeWiseNoShowsDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view)
    @view = view
    @sort_column_names = {
      employee_id: "emp_id",
      employee_name: "employee_name",
      total_rides: "",
      no_shows: ""
    }
  end

  def as_json(options = {})
    count = get_trips.length
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data
    }
  end

  def csv
    CSV.generate do |csv|
      csv << @sort_column_names.keys.map{ |x| x.to_s.camelize.to_sym }
      get_trips.map { |employee_id, trip| csv << Reports::ReportEmployeeWiseNoShowDatatable.new(employee_id, trip).data.values }
    end
  end

  private

  def data
    all_trips.map { |employee_id, trip| Reports::ReportEmployeeWiseNoShowDatatable.new(employee_id, trip).data }
  end

  def all_trips
    Kaminari.paginate_array(get_trips).page(page).per(per_page)
  end

  def get_trips
    sort_val = @sort_column_names[get_sort_params.to_sym].present? ? @sort_column_names[get_sort_params.to_sym] : "emp_id"
    Trip.completed
        .joins(:employee_trips)
        .joins("left outer join employees ON employees.id = employee_trips.employee_id")
        .joins("left outer join users on users.entity_id = employees.id and users.entity_type = 'Employee'")
        .select("employees.employee_id as emp_id,CONCAT('', users.f_name,users.m_name,users.l_name) AS employee_name,employee_trips.status as employee_trip_status,trips.id")
        .where("employee_trips.date BETWEEN '#{filter_params.symbolize_keys[:startDate]}' AND '#{filter_params.symbolize_keys[:endDate]}'")
        .order("#{sort_val} #{sort_direction}")
        .distinct.group_by(&:emp_id).to_a
  end

  # get data from filter
  def filter_params
    today = Time.zone.now.beginning_of_day.in_time_zone('UTC')
    startdate = params['startDate'].blank? ? (today - 1.month) : Time.zone.parse(params['startDate'] + " IST").in_time_zone('UTC')
    endDate = params['endDate'].blank? ? today : Time.zone.parse(params['endDate'] + " IST").in_time_zone('UTC')
    {
        'startDate' => startdate,
        'endDate'=> endDate
    }
  end

end
