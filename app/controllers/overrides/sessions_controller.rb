module Overrides
  class SessionsController < DeviseTokenAuth::SessionsController

    # Changes:
    # - Use email/username/phone for login
    def create
      # Check
      field = (resource_params.keys.map(&:to_sym) & resource_class.authentication_keys).first

      @resource = nil

      if field
        q_value = resource_params[field]

        if resource_class.case_insensitive_keys.include?(field)
          q_value.downcase!
        end

        q = "#{field.to_s} = ? AND provider='email'"

        if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
          q = "BINARY " + q
        end

        # Log in with email or username or password
        @resource = resource_class.where('email = ? OR username = ? OR phone = ?', q_value, q_value, q_value).first

      end

      app = resource_params[:app]
      if app.blank?
        render_create_error_app_not_specified
      elsif @resource and valid_params?(field, q_value) and @resource.valid_password?(resource_params[:password]) and (!@resource.respond_to?(:active_for_authentication?) or @resource.active_for_authentication?) and @resource.has_access_to_app?(resource_params[:app])

        # create client id
        @client_id = SecureRandom.urlsafe_base64(nil, false)
        @token     = SecureRandom.urlsafe_base64(nil, false)

        @resource.tokens[@client_id] = {
            token: BCrypt::Password.create(@token),
            expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
        }

        if resource_params[:app] == "driver"
          @resource.status = 2
        end

        @resource.save

        sign_in(:user, @resource, store: false, bypass: false)

        yield @resource if block_given?

        render_create_success
      elsif @resource and not @resource.has_access_to_app?(resource_params[:app])
        render_create_error_use_other_app
      elsif @resource and not (!@resource.respond_to?(:active_for_authentication?) or @resource.active_for_authentication?)
        render_create_error_not_confirmed
      else
        render_create_error_bad_credentials
      end
    end

    protected
    # Changes:
    # - removed data from response structure
    def render_create_success
      render json: resource_data(resource_json: @resource.token_validation_response)
    end

    # User tries to log in to incorrect app
    def render_create_error_use_other_app
      render json: {
                 success: false,
                 errors: [ "Please use #{@resource.role.capitalize} app" ]
             }, status: 403
    end

    # App type parameter missed
    def render_create_error_app_not_specified
      render json: {
                 success: false,
                 errors: ['Please specify app type in your request: driver or employee']
             }, status: 422
    end

    private

    # Changes:
    # - add custom parameters to request
    def resource_params
      custom_params = [ :app ]
      params.permit(*params_for_resource(:sign_in) + custom_params)
    end

  end
end
