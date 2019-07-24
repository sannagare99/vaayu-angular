class InvoicesDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view, user = nil)
    @view = view
    @user = user
  end

  def as_json(options = {})
    count = get_invoces.count
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data
    }
  end

  def get_invoces
    invoices = case @user.role
                  when 'employer'
                    Invoice.where(:company => @user.entity.employee_company).order("#{sort_column} #{sort_direction}")
                  when 'operator'
                    Invoice.where(:company => get_companies(@user.entity.logistics_company_id)).order("#{sort_column} #{sort_direction}")
                  when 'admin'
                    Invoice.where(:company_type => params['company_type']).order("#{sort_column} #{sort_direction}")
                  else
                    []
                end
  end

  # get companies for current user
  def get_companies user_company_id
    if params['company_type'] == 'BusinessAssociate'
      companies = BusinessAssociate.where( :logistics_company_id => user_company_id)
    elsif params['company_type'] == 'EmployeeCompany'
      companies = EmployeeCompany.where( :logistics_company_id => user_company_id)
    else
      []
    end
    companies
  end

  private

  def data
    all_invoces.map do |invoice|
      InvoiceDatatable.new(invoice).data
    end
  end

  def all_invoces
    @invoice ||= fetch_invoice
  end

  def fetch_invoice
    invoice = get_invoces
    invoice = invoice.page(page).per(per_page)
    invoice
  end

  def possible_sort_columns
    %w[id date status company trips_count amount]
  end

end
