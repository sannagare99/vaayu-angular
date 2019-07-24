namespace :google_api_key do
  desc 'Add Google API Key. eg.) bundle exec rake google_api_key:add api_key=<google_api_key>'
  task :add => [:environment] do
    GoogleAPIKey.create(key: ENV['api_key'])
  end

  desc 'Disable Google API Key. eg.) bundle exec rake google_api_key:disable api_key=<google_api_key>'
  task :disable => [:environment] do
    GoogleAPIKey.find_by(key: ENV['api_key'])&.disable!
  end
end
