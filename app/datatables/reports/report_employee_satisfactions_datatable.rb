class Reports::ReportEmployeeSatisfactionsDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view)
    @view = view
    @sort_column_names = {
      date: "date",
      trip_id: "trip_id",
      status: "trip_status",
      shift_type: "shift_type",
      shift_time: "shift_time",
      vehicle_no: "vehicle_no",
      employee_id: "employee_id",
      employee_name: "employee_name",
      rating: "rating",
      rating_feedback: ""
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
      all_trips.map { |et| csv << Reports::ReportEmployeeSatisfactionDatatable.new(et).data.values }
    end
  end

  private

  def data
    all_trips.map { |et| Reports::ReportEmployeeSatisfactionDatatable.new(et).data }
  end

  def all_trips
    @trip ||= get_trips.page(page).per(per_page)
  end

  def get_trips
    sort_val = @sort_column_names[get_sort_params.to_sym].present? ? @sort_column_names[get_sort_params.to_sym] : "date"

                  # DATE(employee_trips.date) as date,

    EmployeeTrip.joins(trip: :vehicle, employee: :user)
                .select("
                  employee_trips.id,
                  employee_trips.date,
                  CONCAT_WS('',users.f_name,users.m_name,users.l_name) AS employee_name,
                  vehicles.plate_number as vehicle_no,
                  employee_trips.trip_type as shift_type,
                  employee_trips.trip_type,
                  DATE_FORMAT(employee_trips.date, '%H:%i') as shift_time,
                  employee_trips.trip_id,
                  employee_trips.rating,
                  employees.employee_id,
                  trips.status as trip_status,
                  employee_trips.rating_feedback
                  ")
                .where("employee_trips.date BETWEEN '#{filter_params.symbolize_keys[:startDate]}' AND '#{filter_params.symbolize_keys[:endDate]}' and employee_trips.rating is not null")
             .order("#{sort_val} #{sort_direction}")
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
