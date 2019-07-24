class Reports::ReportEmployeeActivitiesDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view)
    @view = view
    @sort_column_names = {
      first_name: "",
      last_name: "",
      employee_id: "",
      phone: "",
      email: "",
      site: "",
      sign_ins: "",
      current_sign_in_at: "",
      last_sign_in_at: "",
      last_active_at: "",
      last_active: "",
      status: ""
    }
  end

  def as_json(options = {})
    count = get_employees.length
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
      get_employees.map { |emp| csv << Reports::ReportEmployeeActivityDatatable.new(emp).data.values }
    end
  end

  private

  def data
    all_employees.map { |emp| Reports::ReportEmployeeActivityDatatable.new(emp).data }
  end

  def all_employees
    @emp ||= get_employees.page(page).per(per_page)
  end

  def get_employees
    sort_val = @sort_column_names[get_sort_params.to_sym].present? ? @sort_column_names[get_sort_params.to_sym] : "employees.employee_id"
    Employee.includes(:user => { :entity => [:employee_company, :site]}).order("#{sort_val} #{sort_direction}")
  end
end
