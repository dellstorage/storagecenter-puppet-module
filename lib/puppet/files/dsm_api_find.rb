class DSMAPIFind
	
	attr_accessor :facts, :sc
	
	def self.find(url, filter)
	  # Utility method
		resp = DSMAPIRequest.post(url, filter)
		DSMAPIRequest.check_resp(resp, url)
		list = JSON.parse(resp.body)
		list
	end
	
	def self.find_server(name, sc)
		Puppet.debug "Inside find_server method of DSMAPIFind."
		
		# Set URL
		url = "#{$base_url}/StorageCenter/ScServer/GetList"
		
		# Create filter
		filter = DSMAPIRequest.define_filter([
			["name", name, "Equals"],
			["scSerialNumber", sc.to_i, "Equals"],
			["serverFolderPath", "puppet", "StartsWith"]
		])
		
		# Handle response
		serv_list = find(url, filter)
		id = find_in_response_array(serv_list, "instanceId")
		if id
			Puppet.info "Server '#{name}' found with id #{id}."
		else
			Puppet.info "Server '#{name}' not found."
		end
		
		# Return id
		id
	end
	
	def self.find_volume(name, sc)
		Puppet.debug "Inside find_volume method of DSMAPIFind."
		
		# Set URL
		url = "#{$base_url}/StorageCenter/ScVolume/GetList"
		
		# Create folder
		filter = DSMAPIRequest.define_filter([
			["name", name, "Equals"],
			["scSerialNumber", sc.to_i, "Equals"],
			["volumeFolderPath", "puppet", "StartsWith"]
		])
		
		# Handle response
		vol_list = find(url, filter)
		id = find_in_response_array(vol_list, "instanceId")
		if id
			Puppet.info "Volume '#{name}' found with id #{id}."
		else
			Puppet.info "Volume '#{name}' not found."
		end
		
		# Return id
		id
	end
	
	def self.find_in_response_array(resp_array, str)
		# Utility method to parse response
		subject = nil
		unless resp_array.kind_of?(Array)
			subject = resp_array[str]
			return subject
		end
		unless resp_array.empty?
			resp_array.each do |resp|
				unless resp.kind_of?(Array)
					subject = resp[str]
				end
			end
		end
		subject
	end
end