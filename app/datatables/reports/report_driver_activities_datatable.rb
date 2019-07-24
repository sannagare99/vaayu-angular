class Reports::ReportDriverActivitiesDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view)
    @view = view
    @sort_column_names = {
      first_name: "",
      last_name: "",
      phone: "",
      driver_license: "",
      last_used_vehicle: "",
      site: "",
      vendor_id: "",
      sign_ins: "",
      current_sign_in_at: "",
      last_sign_in_at: "",
      last_active_at: "",
      last_active: ""
    }
  end

  def as_json(options = {})
    count = get_drivers.length
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
      get_drivers.map { |emp| csv << Reports::ReportDriverActivityDatatable.new(emp).data.values }
    end
  end

  private

  def data
    all_employees.map { |emp| Reports::ReportDriverActivityDatatable.new(emp).data }
  end

  def all_employees
    @emp ||= get_drivers.page(page).per(per_page)
  end

  def get_drivers
    sort_val = @sort_column_names[get_sort_params.to_sym].present? ? @sort_column_names[get_sort_params.to_sym] : "drivers.id"
    Driver.includes(:user => { :entity => [:site]}).includes(:vehicle).order("#{sort_val} #{sort_direction}")
  end
end
