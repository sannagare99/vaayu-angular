class SendDriverOnLeave
  include Sidekiq::Worker
  sidekiq_options :retry => 3, :dead => false

  # check if driver is assigned,
  # if not -- reject manifest, set proper status
  # and send proper notifications
  def perform(request_id, driver_id, flag)
    @driver_request = DriverRequest.find(request_id)

    @driver = Driver.find(driver_id)

    if @driver.blank? || @driver_request.blank?
      return
    end

    if @driver_request.approved?
      if flag == 'off_duty' && @driver.on_leave?
        @driver.go_off_duty! 
      end
      if flag == 'on_leave'
        @driver.go_on_leave!
      end
      @driver_request.notify_driver_about_change_in_status
    end
  end
  
end
