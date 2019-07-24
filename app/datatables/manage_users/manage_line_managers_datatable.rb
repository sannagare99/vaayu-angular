class ManageUsers::ManageLineManagersDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    count = LineManager.count
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data
    }
  end

  private

  def data
    line_managers.map do |line_manager|
      ManageUsers::ManageLineManagerDatatable.new(line_manager.user).data
    end
  end

  def line_managers
    @line_managers ||= fetch_line_managers
  end

  def fetch_line_managers
    line_managers = LineManager.order("#{sort_column} #{sort_direction}")
    line_managers = line_managers.page(page).per(per_page)
    line_managers
  end

  def possible_sort_columns
    %w[id email]
  end
end
