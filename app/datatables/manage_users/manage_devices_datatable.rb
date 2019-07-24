class ManageUsers::ManageDevicesDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    count = devices.count
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data
    }
  end

  private

  def data
    devices.map do |device|
      ManageUsers::ManageDeviceDatatable.new(device).data
    end
  end

  def devices
    @devices ||= fetch_device
  end

  def fetch_device
    devices = Device.order("#{sort_column} #{sort_direction}")
    devices = devices.page(page).per(per_page)
    devices
  end

  def possible_sort_columns
    %w[id email]
  end
end
