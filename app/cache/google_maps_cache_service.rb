class GoogleMapsCacheService
CACHE_ENABLED_METHODS=['directions','geocode','distance_matrix']

	def self.isCacheEnabled(methodName)
		return CACHE_ENABLED_METHODS.include?(methodName)
	end

	def self.put(methodName,args,value_str)

		key_name=get_cache_key(methodName,args)
		Rails.logger.info "Inside put---#{key_name}"
		insert_or_update(key_name,value_str,methodName)
	end

	def self.get(methodName,args)
		key_name=get_cache_key("#{methodName}",args)
		Rails.logger.info "Inside get---for -- #{methodName} key #{key_name}"
		googleMapsCache=get_cache_obj(key_name,methodName)
		if !googleMapsCache.nil?
			return googleMapsCache.value_str
		else
			return nil
		end

		
	end


	def self.get_cache_key(methodName,args)
		Rails.logger.info "Inside get key-#{methodName}--#{args}"
		key_name=''
		case methodName

			when "directions"
				key_name=''
				
				if args[0].class.name.downcase.include? "hash"
					key_name=args[0].values.join("-")
				else
					key_name=args[0].join("-")
				end

				if args[1].class.name.downcase.include? "hash"
					key_name+="-"+args[1].values.join("-")
				else
					key_name+="-"+args[1].join("-")
				end
				
				
				if !args[2][:waypoints].nil?
					
					key_name+="#{args[2][:waypoints].join('-')}"
					
				end

			when  "geocode"
				if !args[0].nil?
					key_name="#{args[0]}"
				end

			when "distance_matrix"
				if args[0].class.name.downcase.include? "hash"
					key_name=args[0].values.join("-")
				else
					key_name=args[0].join("-")
				end

				if args[1].class.name.downcase.include? "hash"
					key_name+="-"+args[1].values.join("-")
				else
					key_name+="-"+args[1].join("-")
				end
				
				

		end
		return key_name;
	end


	def self.insert_or_update(key_name,value_str,methodName)
		begin
			googleMapsCache=get_cache_obj(key_name,methodName)

			if googleMapsCache.nil?
				googleMapsCache=GoogleMapsCache.new(key_str:key_name,value_str:value_str,api_type:methodName,created:Time.now)
			else
				googleMapsCache.value_str=value
			end
			googleMapsCache.updated=Time.now
			googleMapsCache.save
		rescue
			Rails.logger.info "Error insertingkey-#{key_name}--value-#{value_str}"
		end
	end

	def self.get_cache_obj(key_value,methodName)
		return GoogleMapsCache.find_by key_str:key_value, api_type:methodName
	end
end
