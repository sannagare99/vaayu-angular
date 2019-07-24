class ConfigNotSetError < StandardError; end

class Configurator < ApplicationRecord
  enum conf_type: [:boolean, :string, :time, :dropdown]
  serialize :options

  def self.get(config)
    self.find_by(request_type: config).value
  rescue
    raise ConfigNotSetError, "Config '#{config}' not set"
  end

  def self.update_configuration(configurator_params)
    configurator_params.each do |k,v|
      conf = Configurator.find_by(request_type: k)
      next if conf.blank?
      # v.blank? ? conf.destroy : conf.update(value: v)
      conf.update(value: v)
    end
  end

  #Configuration channel
  # 0 - Both
  # 1 - SMS
  # 2 - Notification
  def self.get_notifications_channel(configuration_param)
    notification_channel = {
      sms: false,
      notification: true
    }
    if get(configuration_param) == '1'
      notification_channel[:sms] = true
    end

    notification_channel
  end

  def self.update_google_api(google_params)
    ids = google_params.values.map { |x| x[:google_api_key_id] }.reject(&:blank?).uniq
    GoogleAPIKey.all.each { |x| x.destroy if !ids.include? x.id.to_s}

    google_params.values.each do |google_param|
      if google_param[:google_api_key_id].present?
        google_config = GoogleAPIKey.find(google_param[:google_api_key_id])
        google_param[:google_api_key].blank? ? google_config.destroy : google_config.update(key: google_param[:google_api_key])
      else
        GoogleAPIKey.create({key: google_param[:google_api_key]})
      end
    end
  end
end
