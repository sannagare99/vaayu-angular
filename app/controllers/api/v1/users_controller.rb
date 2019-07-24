module API::V1
  class UsersController < BaseController

    skip_before_action :authenticate_user!

    api :GET, '/users/verify_email'
    description 'Validate email already present in the system'
    param :email, String
    param :phone, String
    formats [ :json ]
    example'
    {
      "status": "created"
    }'
    def verify_email
      @errors = ["Please provide Email or Phone."]
      render 'api/v1/base/_errors', status: 400 and return if params[:email].blank? && params[:phone].blank?
      user = params[:email].present? ? User.find_by_email(params[:email]) : User.find_by_phone(params[:phone])
      if user.present? && (user.driver? || user.employee?)
        if !user.pending?
          @errors = ["You are already registerd. Try signing in instead"]
          render 'api/v1/base/_errors', status: 405          
        else
          render json: user.as_json(only: [:id, :status, :email, :f_name, :l_name, :phone]), status: 200
        end
      else
        @errors = ["user not found"]
        render 'api/v1/base/_errors', status: 404
      end
    end

    api :POST, 'users/set_password'
    description 'Set users password'
    param :id, :number, required: true
    param :password, String, required: true
    param :password_confirmation, String, required: true
    formats [:json]
    error code: 404, desc: 'Not found'
    example'{ "status": "Success" }'
    def set_password
      user = User.find_by_id(params[:id])
      if user.present?
        if user.update({password: params[:password], password_confirmation: params[:password_confirmation]})
          status = user.employee? ? 1 : 2
          user.update_status(status) if user.status.nil? || user.status == "pending"
          render json: { message: "Success", status: user.status }, status: 200
        else
          @errors = user.errors.full_messages
          render "api/v1/base/_errors", status: 400
        end
      else
        @errors = ["User not found"]
        render "api/v1/base/_errors", status: 404
      end
    end
  end
end
