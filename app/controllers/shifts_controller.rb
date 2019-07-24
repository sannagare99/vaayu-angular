class ShiftsController < ApplicationController
  before_action :set_shift, only: [:show, :edit, :update, :destroy, :change_status]
  before_action :active_shift_present, only: :change_status

  # GET /shifts
  # GET /shifts.json
  def index
    render json: Provisioning::ManageShiftsDatatable.new(view_context)
  end

  # GET /shifts/1
  # GET /shifts/1.json
  def show
  end

  # GET /shifts/new
  def new
    @shift = Shift.new
  end

  # GET /shifts/1/edit
  def edit
  end

  # POST /shifts
  # POST /shifts.json
  def create
    @shift = Shift.new(shift_params)
    @shift.save
    @errors = @shift.errors.full_messages.to_sentence
    @datatable_name = "shifts"

    respond_to do |format|
      format.js { render file: "shared/create" }
      format.html { redirect_to provisioning_path(anchor: @datatable_name) }
    end
  end

  # PATCH/PUT /shifts/1
  # PATCH/PUT /shifts/1.json
  def update
    @shift.update(shift_params)
    @errors = @shift.errors.full_messages.to_sentence
    @datatable_name = "shifts"

    respond_to do |format|
      format.js { render file: "shared/create" }
      format.html { redirect_to provisioning_path(anchor: @datatable_name) }
    end
  end

  # DELETE /shifts/1
  # DELETE /shifts/1.json
  def destroy
    @shift.destroy
    respond_to do |format|
      format.html { redirect_to shifts_url, notice: 'Shift was successfully destroyed.' }
      # format.json { head :no_content }
    end
  end

  def change_status
    @shift.send(params[:status].concat("!").to_sym)
  end

  def validate
    shift = if params[:id].present?
      obj = Shift.find(params[:id])
      obj.assign_attributes(shift_params)
      obj
    else
      Shift.new(shift_params)
    end
    shift.valid?
    render json: shift.errors.messages, status: 200
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shift
      @shift = Shift.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shift_params
      params.require(:shift).permit(:name, :start_time, :end_time, :status)
    end

    def active_shift_present
      render json: 'Sorry, Shift has few upcoming trips. So we cant deactivate', status: '401' and return if @shift.employee_trips.upcoming.present?
    end
end
