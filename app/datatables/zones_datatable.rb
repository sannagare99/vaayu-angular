class ZonesDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    count = Zone.count
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data
    }
  end

  private

  def data
    zones.map do |zone|
      ZoneDatatable.new(zone).data
    end
  end

  def zones
    @zones ||= fetch_zones
  end

  def fetch_zones
    zone = Zone.order("#{sort_column} #{sort_direction}")
    zone = zone.page(page).per(per_page)
    zone
  end

  def possible_sort_columns
    %w[id name]
  end
end
