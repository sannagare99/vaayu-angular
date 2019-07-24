class GoogleService
  def api_key
    GoogleAPIKey.working.first
  end

  def client
    key = api_key.key rescue Configurator.get('GOOGLE_MAPS_API_KEY')
    GoogleMapsService::Client.new(
      key: key,
      retry_timeout: 20,
      queries_per_second: 10
    )
  end

  def method_missing(method, *args, &block)
    #args_in_srt=args.sort_by{|x,y|y}
    isCacheEnabled=GoogleMapsCacheService.isCacheEnabled("#{method}")
    mName="#{method}"
    if(isCacheEnabled)
      Rails.logger.info("Cache exists key----#{GoogleMapsCacheService.get_cache_key(mName,args)}")
      value=GoogleMapsCacheService.get(method,args);
 
        if !value.nil?
           Rails.logger.info "value present in db for key---#{method}"
          return JSON.parse(value,:symbolize_names => true);
        end
    end
    
    Rails.logger.info "cache miss for #{method}--#{isCacheEnabled}"

    response=client.send(method, *args, &block)
    
     if (isCacheEnabled && !response.nil?)
      GoogleMapsCacheService.put("#{method}",args,response.to_json)
    end
    return response;
  rescue GoogleMapsService::Error::RateLimitError
    api_key.rate_limit!
     Retry call with new key
    send(method, *args, &block)

  end


end
