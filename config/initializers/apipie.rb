Apipie.configure do |config|
  config.app_name                = "Moove"
  config.api_base_url            = "/api/v1"
  config.doc_base_url            = "/apipie"
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/v1/**/*.rb"

  # Turn off apipie validation
  config.validate_value = false

  # Secure api docs with password
  config.authenticate = Proc.new do
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV['BASIC_AUTH_USER'] && password == ENV['BASIC_AUTH_PASSWORD']
    end
  end
end
