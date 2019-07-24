class UserController < ApplicationController

  before_action :set_user, only: [:edit, :update, :destroy]

  def index
    @users = User.all
  end

  def new

  end

  def create

  end

  def edit

  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to user_profile_edit_path, notice: 'Congratulations! Your profile was successfully updated.' }
      else
        format.html { render :'home/profile_edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy

  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(
          :id, :f_name, :m_name, :l_name, :email, :role, :phone, :avatar
      )
    end

end
