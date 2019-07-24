namespace :site do
  	desc 'Set billing parameters for existing sites'
  	task :set_billing_parameters => [:environment] do
  		@site = Site.all
    	@site.each do |s|
		  	@service = Service.create(:site_id => s.id,
		                              :service_type => 'Door To Door',
		                              :billing_model => 'Fixed Rate per Trip',
		                              :vary_with_vehicle => 0
		                            )
		    
		    @vehicle_rate = VehicleRate.create(:service_id => @service.id,
		                                           :vehicle_capacity => 0,
		                                           :ac => 1,
		                                           :cgst => 9,
		                                           :sgst => 9,
		                                           :overage => 0,
		                                           :time_on_duty => nil,
		                                           :overage_per_hour => nil
		                                        )        
		    @zone_rate = ZoneRate.create(:vehicle_rate_id => @vehicle_rate.id,
		                                 :name => 'Default',
		                                 :rate => 100,
		                                 :guard_rate => 100
		                                )
  	end
  end
end
