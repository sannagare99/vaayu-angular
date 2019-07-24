class Billing::CustomerInvoicesDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view, invoices = nil, user)
    @view = view
    @invoices = invoices
    @user = user
  end

  def as_json(options = {})
    count = get_invoices.length
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data,
        user: @user
    }
  end

  private

  def data
    all_invoices.map { |invoice| Billing::CustomerInvoiceDatatable.new(invoice).data }
  end

  def all_invoices
    @invoice ||= get_invoices.page(page).per(per_page)
  end

  def get_invoices
    Invoice.where(:date => filter_params['startDate']..filter_params['endDate']).order(id: :desc)
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
