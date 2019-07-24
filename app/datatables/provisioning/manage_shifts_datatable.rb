class Provisioning::ManageShiftsDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    count = Shift.count
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data
    }
  end

  private

  def data
    shifts.map do |shift|
      Provisioning::ManageShiftDatatable.new(shift).data
    end
  end

  def shifts
    shifts = Shift.order("#{sort_column} #{sort_direction}")
    params[:paginate].nil? ? shifts.page(page).per(per_page) : shifts
  end

  def possible_sort_columns
    %w[id name]
  end

end
