class ManageUsers::ManageEmployeesDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view, employees=[])
    @view = view
    @employees = employees
    @count = employees.count
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: @count,
        iTotalDisplayRecords: @count,
        aaData: data
    }
  end

  private

  def data
    employees.map do |employee|
      ManageUsers::ManageEmployeeDatatable.new(employee.user, params).data
    end
  end

  def employees
    employees = @employees.order("#{sort_column} #{sort_direction}")
    employees = employees.page(page).per(per_page) if params[:paginate].nil?
    employees
  end

  # ToDo: Remove this method if unused
  # def fetch_employees
  #   employees = Employee.order("#{sort_column} #{sort_direction}")
  #   employees = employees.page(page).per(per_page)
  #   employees
  # end

  def select_options
    {
        'entity_attributes.zone_id' =>  Zone.all.map{ |z| { "label": z.name, "value": z.id }},
        'entity_attributes.site_id' =>  Site.all.map{ |s| { "label": s.name, "value": s.id }}
    }
  end

  def possible_sort_columns
    %w[id email]
  end

end
