class ManageUsers::ManageTransportDeskManagersDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    count = TransportDeskManager.count
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data
    }
  end

  private

  def data
    transport_desk_managers.map do |transport_desk_manager|
      ManageUsers::ManageTransportDeskManagerDatatable.new(transport_desk_manager.user).data
    end
  end

  def transport_desk_managers
    @transport_desk_managers ||= fetch_transport_desk_managers
  end

  def fetch_transport_desk_managers
    transport_desk_managers = TransportDeskManager.order("#{sort_column} #{sort_direction}")
    transport_desk_managers = transport_desk_managers.page(page).per(per_page)
    transport_desk_managers
  end

  def possible_sort_columns
    %w[id email]
  end
end
