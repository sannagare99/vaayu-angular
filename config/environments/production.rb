Rails.application.configure do
 
  config.cache_classes = false
  
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::KeyValue.new
  config.logger = ActiveSupport::Logger.new(STDOUT)
  config.log_level = :debug
  
  config.eager_load = false

  config.consider_all_requests_local = true

  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  config.active_support.deprecation = :log

  config.active_record.migration_error = :page_load
  config.assets.debug = true

  config.assets.quiet = true

  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # ActionMailer configs
  ActionMailer::Base.default :from => ENV['GMAIL_USENAME']

  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
      address:              'smtp.gmail.com',
      port:                 587,
      domain:               'localhost',
      user_name:            ENV['GMAIL_USENAME'],
      password:             ENV['GMAIL_PASSWORD'],
      authentication:       'plain',
      enable_starttls_auto: true
  }

  Humanize.configure do |config|
    config.default_locale = :en  # [:en, :fr], default: :en
    config.decimals_as = :digits # [:digits, :number], default: :digits
  end

  Paperclip.options[:command_path] = "/usr/local/bin/"

  config.paperclip_defaults = {
      :url => ':s3_domain_url',
      :path => '/:class/:attachment/:id_partition/:style/:filename',
      :storage => :s3,
      :s3_region => 'ap-south-1',
      :s3_credentials => {
        :access_key_id => ENV['S3_ACCESS_KEY_ID'],
        :secret_access_key => ENV['S3_SECRET_KEY'],
        :bucket => ENV['S3_BUCKET'],
      }
  }
  # config.after_initialize do
  #   Bullet.enable = true
  #   Bullet.console = true
  #   Bullet.rails_logger = true
  #   Bullet.bullet_logger = true
  #   Bullet.add_footer = true
  # end

end
