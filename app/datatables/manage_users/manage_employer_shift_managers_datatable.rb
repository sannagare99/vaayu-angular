class ManageUsers::ManageEmployerShiftManagersDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    count = EmployerShiftManager.count
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data
    }
  end

  private

  def data
    employer_shift_managers.map do |employer_shift_manager|
      ManageUsers::ManageEmployerShiftManagerDatatable.new(employer_shift_manager.user).data
    end
  end

  def employer_shift_managers
    @employer_shift_managers ||= fetch_employer_shift_managers
  end

  def fetch_employer_shift_managers
    employer_shift_managers = EmployerShiftManager.order("#{sort_column} #{sort_direction}")
    employer_shift_managers = employer_shift_managers.page(page).per(per_page)
    employer_shift_managers
  end

  def possible_sort_columns
    %w[id email]
  end
end
