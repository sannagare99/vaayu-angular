class VehiclesDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view, vehicle=[])
    @view = view
    search_input = params[:search_input]
    search_by = params[:search_by]
    if search_input.present?
      @count = Vehicle.where("#{search_by} LIKE ?", "%#{search_input}%").count
    else
      @count = Vehicle.count
    end
  end

  def as_json(options = {})
    count = @count
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data
    }
  end

  private

  def data
    vehicles.map do |company|
      VehicleDatatable.new(company).data
    end
  end

  def vehicles
    @vehicles ||= fetch_vehicles
  end

  def fetch_vehicles
    start = params["start"]
    search_by = params[:search_by]
    search_input = params[:search_input]
    if search_input.present?
      Vehicle.eager_load([:business_associate, :driver => [:user]]).where("#{search_by} LIKE ?", "%#{search_input}%").order('vehicles.sort_status desc').order('vehicles.created_at desc').offset(start).limit(per_page)
    else
      Vehicle.eager_load([:business_associate, :driver => [:user]]).order('vehicles.sort_status desc').order('vehicles.created_at desc').offset(start).limit(per_page)
    end
  end

  def possible_sort_columns
    %w[id]
  end
end
