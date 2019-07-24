class ZonesController < ApplicationController
  before_action :set_zone, only: [:update, :destroy]

  def index
    respond_to do |format|
      format.html
      format.json { render json: ZonesDatatable.new(view_context)}
    end
  end

  def new
    @zone = Zone.new
  end

  def edit
    @zone = Zone.find(params[:id])
    render :new
  end

  def create
    if current_user.employer? || current_user.admin?
      @zone = Zone.new(zone_params)
      @zone.save
    end
    @errors = @zone.errors.full_messages.to_sentence
    @datatable_name = "zones"

    respond_to do |format|
      format.js { render file: "shared/create" }
      format.html { redirect_to provisioning_path(anchor: @datatable_name) }
    end
  end

  def update
    # TODO: use CanCan gem
    @zone.update(zone_params) if current_user.admin? || current_user.employer?
    @errors = @zone.errors.full_messages.to_sentence
    @datatable_name = "zones"

    respond_to do |format|
      format.js { render file: "shared/create" }
      format.html { redirect_to provisioning_path(anchor: @datatable_name) }
    end
  end

  def destroy
    if current_user.admin? || current_user.operator? || current_user.employer?
      @zone.destroy
      respond_to do |format|
        format.json { head :no_content }
      end
    end
  end

  private

  def set_zone
    @zone = Zone.find_by_prefix(params[:id])
  end

  def zone_params
    params.require(:zone).permit(:id, :name)
  end

end
