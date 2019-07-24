class ManageUsers::ManageOperatorShiftManagersDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    count = OperatorShiftManager.count
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data
    }
  end

  private

  def data
    operator_shift_managers.map do |operator_shift_manager|
      ManageUsers::ManageOperatorShiftManagerDatatable.new(operator_shift_manager.user).data
    end
  end

  def operator_shift_managers
    @operator_shift_managers ||= fetch_operator_shift_managers
  end

  def fetch_operator_shift_managers
    operator_shift_managers = OperatorShiftManager.order("#{sort_column} #{sort_direction}")
    operator_shift_managers = operator_shift_managers.page(page).per(per_page)
    operator_shift_managers
  end

  def possible_sort_columns
    %w[id email]
  end
end
