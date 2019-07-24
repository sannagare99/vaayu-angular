class SendDriverOffDuty
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  sidekiq_options :retry => 3, :dead => false

  # Every day at 00:01
  recurrence { daily.hour_of_day(21).minute_of_hour(30) }

  def perform
    send_drivers_off_duty
  end

  def send_drivers_off_duty
    send_drivers_off_duty = Configurator.where(:request_type => 'send_drivers_off_duty').first

    if send_drivers_off_duty.present? && send_drivers_off_duty.value == '1'
      # Fetch all on_duty drivers and make them off_duty
      @drivers = Driver.on_duty
      @drivers.each do |driver|
      	driver.send_off_duty
      end
    end
  end
  
end
