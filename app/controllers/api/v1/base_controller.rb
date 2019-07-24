module API::V1
  class BaseController < ApplicationController
    include DeviseTokenAuth::Concerns::SetUserByToken

    protect_from_forgery with: :null_session

    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from CanCan::AccessDenied, with: :access_denied

    respond_to :json

    private
      def record_not_found(error)
        render json: { success: false, errors: [ error.message ] }, status: :not_found
      end

      def access_denied(error)
        render json: { success: false, errors: [ error.message ] }, status: 403
      end

  end
end