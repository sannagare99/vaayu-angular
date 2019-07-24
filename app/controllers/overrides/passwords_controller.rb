module Overrides
  class PasswordsController < DeviseTokenAuth::PasswordsController

    protected
    # Changes:
    # - removed data from response structure
    def render_create_success
      render json: {
                 success: true,
                 message: I18n.t("devise_token_auth.passwords.sended", email: @email)
             }
    end

  end
end
