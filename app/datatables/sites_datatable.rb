class SitesDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view, user)
    @view = view
    @user = user
  end

  def as_json(options = {})
    count = get_sites.count
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data,
        user: @user
    }
  end

  def get_sites
    if @user.admin?
      sites = Site.all
    elsif (logistics_company = @user.entity.logistics_company)
      employee_companies = EmployeeCompany.where(:logistics_company => logistics_company)
      sites = Site.where(:employee_company => employee_companies)
    end
    sites
  end

  private

  def data
    sites.map do |company|
      SiteDatatable.new(company).data
    end
  end

  def sites
    @sites ||= fetch_sites
  end

  def fetch_sites
    site = get_sites.order("#{sort_column} #{sort_direction}")
    site = site.page(page).per(per_page)
    site
  end

  def possible_sort_columns
    %w[id name]
  end
end
