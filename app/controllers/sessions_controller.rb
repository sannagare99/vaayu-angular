class SessionsController < Devise::SessionsController
  def new
    super
  end

  def create
    web_app_token = SecureRandom.urlsafe_base64(nil, false)
  end
end