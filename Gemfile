source 'https://rubygems.org'
ruby '2.3.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
# Use mysql2 as the database for Active Record
gem 'mysql2'
# Use passenger as the app server"
gem "passenger"
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data'
# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'touchpunch-rails'
gem 'underscore-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# gem 'turbolinks', '~> 5'
# app now returns a 200 from /healthcheck.
gem 'aws-healthcheck'
gem 'angular-rails-templates'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
gem 'oj'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# User registration: Devise gem
gem 'devise'
gem 'devise_token_auth' # Token based authentication for Rails JSON APIs
gem 'omniauth' # required for devise_token_auth
# gems for frontend
gem 'slim-rails'
# form builder
gem 'simple_form'
# status management
gem 'aasm'
gem 'cancan'
gem 'inline_svg'

gem 'kaminari'
# Brakeman is an open source static analysis tool which checks Ruby on Rails applications for security vulnerabilities.
gem 'brakeman'
# Patch-level verification for bundler
gem 'bundler-audit'

# Rack middleware for blocking & throttling abusive requests
gem 'rack-attack'

# Security related headers all in one gem.
gem 'secure_headers'

group :development, :test do
  gem 'pry-rails'
  gem 'rb-readline'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  # gem 'byebug', platform: :mri
  gem 'pry-byebug'

  # RSpec testing framework
  gem 'rspec-rails', '~> 3.5'
  # RSpec one-liners for common tests
  gem 'shoulda-matchers', '~>4.0.1'

  # Replace fixtures with factories
  gem 'factory_girl_rails', '~> 4.0'

  # Fake test data
  gem 'faker'
  gem 'bullet'
  gem 'rack-mini-profiler'
  gem 'memory_profiler'

  gem 'flamegraph'
  gem 'stackprof'     # For Ruby MRI 2.1+
  gem 'fast_stack'    # For Ruby MRI 2.0
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'puma'
end

gem 'rollbar'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Bower for assets libraries
gem 'rails_12factor', group: :production
gem 'bower-rails', '~> 0.11.0'

# Use font awesome without bower
gem 'font-awesome-rails'
gem 'bootstrap-sass', '~> 3.3.6'
# API Docs
gem 'apipie-rails'

# Use application.yml for config values
gem 'figaro'

# Background jobs
gem 'sidekiq'
gem 'sidetiq'

# Google Maps APIs
gem 'gmaps4rails'
gem 'google_maps_service'

# Push notifications
gem 'fcm'
# generate invoice xls
gem 'axlsx', '~> 2.0'
gem "axlsx_rails"
# hymanize numbers to words
gem 'humanize'
# Paperclip for uploading files
gem 'paperclip'

gem 'aws-sdk'
gem 'browser-timezone-rails'
gem 'remotipart', '~> 1.2'
gem 'plivo'
gem 'httparty'
gem 'kmeans-clusterer'
gem 'faker', require: false

# NewRelic reporting
gem 'newrelic_rpm', group: :production

# Test coverage
gem 'simplecov', :require => false, :group => :test
gem 'c_geohash'
gem 'ransack', '1.8.3'
gem 'whenever'

group :test do
  gem 'cucumber-rails', :require => false
  # database_cleaner is not required, but highly recommended
  gem 'database_cleaner'
  gem 'headless'
  gem 'selenium-webdriver', '2.53.4'
  #gem 'selenium-webdriver', '3.0.0'
  gem 'rspec'
  gem 'geckodriver-helper'
  # Validate json responses structure
  gem 'json-schema'
end

# Logging
gem 'gelf'
gem 'lograge'

gem 'roo'
# Performace Testing
gem 'ruby-jmeter'
