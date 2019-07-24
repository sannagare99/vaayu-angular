class ManageUsers::ManageOperatorsDatatable
  include DatatablePagination

  delegate :params, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    count = Operator.count
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data
    }
  end

  private

  def data
    operators.map do |operator|
      ManageUsers::ManageOperatorDatatable.new(operator.user).data
    end
  end

  def operators
    @operators ||= fetch_operators
  end

  def fetch_operators
    operators = Operator.order("#{sort_column} #{sort_direction}")
    operators = operators.page(page).per(per_page)
    operators
  end

  def possible_sort_columns
    %w[id email]
  end
end
