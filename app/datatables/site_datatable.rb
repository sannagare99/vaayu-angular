class SiteDatatable
  def initialize(site = nil)
    @site = site
  end

  def as_json(options = {})
    {
        :data => data
    }
  end

  def data
    {
       "DT_RowId" => "#{Site::DATATABLE_PREFIX}-#{@site.id}",
       :id => @site.id,
       :name => @site.name,
       :company => @site.employee_company&.name,
       :latitude => @site.latitude,
       :longitude => @site.longitude,
       :address => @site.address,
       :phone => @site.phone.blank? ? '' : @site.phone
    }
  end
end
