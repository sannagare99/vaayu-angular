require 'plivo'
include Plivo

class SMSWorker

  include Sidekiq::Worker
  sidekiq_options :retry => 0, :dead => false

  def perform(to, from, message)
    send_last_mile_sms = Configurator.where(:request_type => 'send_last_mile_sms').first

    if !to.blank? && !to.nil? && !from.blank? && !from.nil? && send_last_mile_sms.present? && send_last_mile_sms.value == '1'
      to = '91' << to
      from = '91' << from

      #p = RestAPI.new( ENV['PLIVO_AUTH_ID'],  ENV['PLIVO_AUTH_TOKEN'])
      #params = {
      #  'src' => from,
      #  'dst' => to,
      #  'text' => message
      #}
      #response = p.send_message(params)
      response = HTTParty.post(URI.escape("https://alerts.solutionsinfini.com/api/v4/?api_key=#{ENV['SOLUTIONS_INFINI_API_KEY']}&method=sms&message=#{message}&to=#{to}&sender=#{ENV['SOLUTIONS_INFINI_SENDER']}"),
      {})
    end
  end
  
end
