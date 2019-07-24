class ManageUsers::ManageDeviceDatatable
  def initialize(device = nil)
    @device = device
  end

  def as_json(options = {})
    {
        :data => data
    }
  end

  def data
    {
        id: @device.id,
        device_id: @device.device_id,
        make: @device.make,
        model: @device.model,
        os: @device.os,
        os_version: @device.os_version,
        status: @device.status&.titleize
    }
  end
end
