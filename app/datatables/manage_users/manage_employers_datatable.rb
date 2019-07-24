class ManageUsers::ManageEmployersDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    count = Employer.count
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data,
        options: select_options
    }
  end

  private

  def data
    employers.map do |employer|
      ManageUsers::ManageEmployerDatatable.new(employer.user).data
    end
  end

  def employers
    @employers ||= fetch_employers
  end

  def fetch_employers
    employers = Employer.order("#{sort_column} #{sort_direction}")
    employers = employers.page(page).per(per_page)
    employers
  end

  def select_options
    {
      'entity_attributes.company' => EmployeeCompany.all.map { |x| { "label": x.name, "value": x.id } }
    }
  end

  def possible_sort_columns
    %w[id email]
  end
end
