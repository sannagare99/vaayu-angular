require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Moove
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.middleware.use Rack::Attack
    config.exceptions_app = self.routes
    config.autoload_paths += %W(#{config.root}/lib)
    config.eager_load_paths << "#{Rails.root}/lib"

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :options], expose: ['client', 'access-token', 'uid']
      end
    end
  end
end