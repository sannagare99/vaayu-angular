class ZoneDatatable
  def initialize(zone = nil)
    @zone = zone
  end

  def as_json(options = {})
    {
        :data => data
    }
  end

  def data
    {
       "DT_RowId" => "#{Zone::DATATABLE_PREFIX}-#{@zone.id}",
       :id => @zone.id,
       :name => @zone.name
    }
  end
end
