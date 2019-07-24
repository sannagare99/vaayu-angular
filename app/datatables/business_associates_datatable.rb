class BusinessAssociatesDatatable
  include DatatablePagination

  delegate :params, to: :@view

  def initialize(view, user)
    @view = view
    @user = user
  end

  def as_json(options = {})
    count = BusinessAssociate.count
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
    b_associates.map do |business_associate|
      BusinessAssociateDatatable.new(business_associate).data
    end
  end

  def b_associates
    @business_associates ||= fetch_b_associates
  end

  def fetch_b_associates
    b_a = BusinessAssociate.order("#{sort_column} #{sort_direction}")
    b_a = b_a.page(page).per(per_page)
    b_a
  end

  def possible_sort_columns
    %w[id name]
  end
end
