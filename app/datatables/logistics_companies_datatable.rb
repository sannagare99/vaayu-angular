class LogisticsCompaniesDatatable
  include DatatablePagination

  delegate :params, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    count = LogisticsCompany.count
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data
    }
  end

  private

  def data
    companies.map do |company|
      LogisticCompanyDatatable.new(company).data
    end
  end

  def companies
    @companies ||= fetch_companies
  end

  def fetch_companies
    company = LogisticsCompany.order("#{sort_column} #{sort_direction}")
    company = company.page(page).per(per_page)
    company
  end

  def possible_sort_columns
    %w[id]
  end
end
