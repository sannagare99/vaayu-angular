class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format.json? }

  around_filter :set_time_zone
  before_action :set_headers
  before_action :authenticate_user!, unless: -> { ['devise_token_auth', 'overrides' ].include?(params[:controller].split('/')[0])}
  around_action :set_current_user

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden }
      format.html { redirect_to main_app.root_url, :alert => exception.message }
    end
  end

  # Overwriting the sign_in redirect path method
  def after_sign_in_path_for(resource_or_scope)
    if current_user.driver? || current_user.employee?
      sign_out current_user
      flash[:notice] = 'Sorry you have not permission for sign in'
    end
    if current_user&.sign_in_count == 1
      user_profile_edit_path
    else
      root_path
    end
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  private
  def set_headers
    response.headers['Server-Timestamp'] = DateTime.now.to_i
  end

  def set_time_zone
    old_time_zone = Time.zone
    Time.zone = browser_timezone if browser_timezone.present?
    yield
  ensure
    Time.zone = old_time_zone
  end

  def browser_timezone
    cookies["browser.timezone"]
  end
  
  def set_current_user
    Current.user = current_user
    yield
  ensure
    # to address the thread variable leak issues in Puma/Thin webserver
    Current.user = nil
  end   
end
