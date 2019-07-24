class Reports::ReportVendorTripDistributionsDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view)
    @view = view
    @sort_column_names = {
        date: "date",
        shift: "",
        direction: "",
        vendor: "",
        trips: "",
        planned_mileage: "",
        actual_mileage: ""
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
      get_trips.map { |trip, detail| csv << Reports::ReportVendorTripDistributionDatatable.new(trip, detail).data.values }
    end
  end

  private

  def data
    all_trips.map { |trip, detail| Reports::ReportVendorTripDistributionDatatable.new(trip, detail).data }
  end

  def all_trips
    Kaminari.paginate_array(get_trips).page(page).per(per_page)
  end

  def get_trips
    sort_val = @sort_column_names[get_sort_params.to_sym].present? ? @sort_column_names[get_sort_params.to_sym] : "trips.id"
    Trip.joins(:employee_trips)
        .joins("left outer join drivers ON drivers.id = trips.driver_id")
        .joins("left outer join logistics_companies on logistics_companies.id = drivers.logistics_company_id")
        .joins("left outer join vehicles on vehicles.id = trips.vehicle_id")
        .select("trips.id,
                 employee_trips.trip_type,
                 trips.scheduled_approximate_distance,
                 trips.planned_approximate_distance,
                 DATE(convert_tz(employee_trips.date,'-05:30', '+00:00')) as date,
                 DATE_FORMAT(convert_tz(employee_trips.date,'-05:30', '+00:00'), '%H:%i') as shift_time,
                 logistics_companies.name as vendor_name")
        .where("employee_trips.date BETWEEN '#{filter_params.symbolize_keys[:startDate]}' AND '#{filter_params.symbolize_keys[:endDate]}'")
        .order("#{sort_val} #{sort_direction}")
        .distinct
        .group_by { |x| [x.date,x.shift_time,x.trip_type,x.vendor_name] }.to_a
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