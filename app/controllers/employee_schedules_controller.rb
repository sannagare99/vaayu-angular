class EmployeeSchedulesController < ApplicationController

  def index
  end

  def edit
    @employee = Employee.find(params[:id])
    @schedule = @employee.employee_schedules
  end

  def update
    @employee = Employee.find(params[:id])
    if @employee.update(schedule_params)
      flash[:notice] = 'Employee Schedule was successfully updated'
    else
      flash[:error] = @employee.errors.full_messages.to_sentence
    end
  end

  private
  def schedule_params
    params.require(:employee).permit!
  end

end
