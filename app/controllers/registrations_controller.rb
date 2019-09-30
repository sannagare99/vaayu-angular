class RegistrationsController < Devise::RegistrationsController
  def new
    @user = User.new
  end

  def create
    byebug
    super
  end

  def update
    super
  end

  private

  def sign_up_params
    allow = [:email, :password, :username]
    params.require(resource_name).permit(allow)
  end
 

end 