require 'sidekiq'
require 'sidekiq/web'

# Use sidekiq as activejob queues
Rails.application.config.active_job.queue_adapter = :sidekiq

# Basic auth for /sidekiq
Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == [ ENV['BASIC_AUTH_USER'], ENV['BASIC_AUTH_PASSWORD'] ]
end

SIDEKIQ_BASE_CONFIG = {
  url: ENV['JOB_WORKER_URL']
}

Sidekiq.configure_server do |config|
  config.redis = SIDEKIQ_BASE_CONFIG
end

Sidekiq.configure_client do |config|
  config.redis = { size: 1 }.merge(SIDEKIQ_BASE_CONFIG)
end
