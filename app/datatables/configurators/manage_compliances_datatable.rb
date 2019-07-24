class Configurators::ManageCompliancesDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: Compliance.count,
        iTotalDisplayRecords: Compliance.count,
        aaData: data
    }
  end

  private

  def data
    compliance.map do |comp|
      Configurators::ManageComplianceDatatable.new(comp).data
    end
  end

  def compliance
    Compliance.all.order("#{sort_column} #{sort_direction}").page(page).per(per_page)
  end

  def possible_sort_columns
    %w[id key]
  end

end
