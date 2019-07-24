class Reports::ReportVehicleDeploymentsDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view)
    @view = view
    @sort_column_names = {
      date: "trip_date",
      ba_name: "ba_name",
      shift_time: "shift_time",
      direction: "trip_type",
      vehicle_deployed: "vehicle_deployed"
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
      get_trips.map { |trip| csv << Reports::ReportVehicleDeploymentDatatable.new(trip).data.values }
    end
  end

  private

  def data
    all_trips.map { |trip| Reports::ReportVehicleDeploymentDatatable.new(trip).data }
  end

  def all_trips
    # @trip ||= get_trips.page(page).per(per_page)
    Kaminari.paginate_array(get_trips).page(page).per(per_page)

  end

  def get_trips
    sort_val = @sort_column_names[get_sort_params.to_sym].present? ? @sort_column_names[get_sort_params.to_sym] : "date"

    Trip.joins(:vehicle, :employee_trips, driver: :logistics_company)
        .select("employee_trips.date as trip_date,logistics_companies.name AS ba_name,trips.trip_type,convert_tz(employee_trips.date,'-05:30', '+00:00') as shift_time,trips.id")
        .where("employee_trips.date BETWEEN '#{filter_params.symbolize_keys[:startDate]}' AND '#{filter_params.symbolize_keys[:endDate]}'")
        .order("date asc")
        .distinct
        .group_by { |x| [x.trip_date, x.ba_name, x.shift_time.strftime("%H:%M"), x.trip_type] }.map { |k,v| k << v.length }
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
