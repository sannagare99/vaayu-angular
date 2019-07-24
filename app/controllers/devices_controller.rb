class DevicesController < ApplicationController
  before_action :set_device, only: [:show, :edit, :update, :destroy]
  before_action :set_drivers, only: [:new, :edit]

  # GET /devices
  # GET /devices.json
  def index
    # @devices = Device.all
    render json: ManageUsers::ManageDevicesDatatable.new(view_context)
  end

  # GET /devices/1
  # GET /devices/1.json
  def show
  end

  # GET /devices/new
  def new
    @device = Device.new
  end

  # GET /devices/1/edit
  def edit
  end

  # POST /devices
  # POST /devices.json
  def create
    @device = Device.new(device_params)
    @device.save
    @errors = @device.errors.full_messages.to_sentence
    @datatable_name = "devices"

    respond_to do |format|
      format.js { render file: "shared/create" }
      format.html { redirect_to provisioning_path(anchor: @datatable_name) }
    end
  end

  # PATCH/PUT /devices/1
  # PATCH/PUT /devices/1.json
  def update
    @device.update(device_params)
    @errors = @device.errors.full_messages.to_sentence
    @datatable_name = "devices"

    respond_to do |format|
      format.js { render file: "shared/create" }
      format.html { redirect_to provisioning_path(anchor: @datatable_name) }
    end
  end

  # DELETE /devices/1
  # DELETE /devices/1.json
  def destroy
    @device.destroy
    respond_to do |format|
      format.html { redirect_to devices_url, notice: 'Device was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def validate
    device = if params[:id].present?
      obj = Device.find(params[:id])
      obj.assign_attributes(device_params)
      obj
    else
      Device.new(device_params)
    end
    device.valid?
    render json: device.errors.messages, status: 200
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_device
      @device = Device.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def device_params
      params.require(:device).permit(:device_id, :make, :model, :os, :os_version, :status, :driver_id)
    end

    def set_drivers
      @drivers = Driver.includes(:user).all.map {|x| [x.full_name, x.id]}
    end
end
