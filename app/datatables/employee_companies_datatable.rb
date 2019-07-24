class EmployeeCompaniesDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    count = EmployeeCompany.count
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
    companies.map do |company|
      EmployeeCompanyDatatable.new(company).data
    end
  end

  def select_options
    {
        'logistics_company_id' =>  LogisticsCompany.all.map{ |z| { "label": z.name, "value": z.id }}
    }
  end

  def companies
    @companies ||= fetch_companies
  end

  def fetch_companies
    company = EmployeeCompany.order("#{sort_column} #{sort_direction}")
    company = company.page(page).per(per_page)
    company
  end

  def possible_sort_columns
    %w[id]
  end
end
