#    Copyright 2016 Dell Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
class DSMAPIFind
	
	attr_accessor :facts, :sc
	
	def self.find(url, filter)
	  # Utility method
		resp = DSMAPIRequest.post(url, filter)
		DSMAPIRequest.check_resp(resp, url)
		list = JSON.parse(resp.body)
		list
	end
	
	def self.find_os(name)
		Puppet.debug "Inside find_os method of DSMAPIFind."
		
		# Make call to find OS
		url = "#{$base_url}/StorageCenter/ScServerOperatingSystem/GetList"
		filter = DSMAPIRequest.define_filter([["name", name, "Equals"]])
		os_list = find(url, filter)
		
		# Handle Response 
		id = find_in_response_array(os_list, "instanceId")
		if id
			Puppet.info "Found Operating System '#{name}' with id #{id}."
		else
			raise ArgumentError, "Operating System '#{name}' is unsupported."
		end
		id
	end
	
	def self.find_server(name, sc)
		Puppet.debug "Inside find_server method of DSMAPIFind."
		
		# Set URL
		url = "#{$base_url}/StorageCenter/ScServer/GetList"
		
		# Create filter
		filter = DSMAPIRequest.define_filter([
			["name", name, "Equals"],
			["scSerialNumber", sc.to_i, "Equals"],
			["serverFolderPath", $puppet_folder, "StartsWith"]
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
			["volumeFolderPath", $puppet_folder, "StartsWith"]
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
	
	def self.find_hba(serv_id, wwn_or_iscsi_name)
		Puppet.debug "Inside find_hba method of DSMAPIFind."
		
		# Make call to find HBA
		url = "#{$base_url}/StorageCenter/ScServer/#{serv_id}/HbaList"
		
		#Handle Response
		resp = DSMAPIRequest.get(url)
		DSMAPIRequest.check_resp(resp, url)
		
		# Retrieve list of HBAs
		hba_list = JSON.parse(resp.body)
		hba_id = nil
		if hba_list.empty?
			return hba_id
		end
		
		# Response is returned as an array
		# Array will only contain one item
		hba_list.each do |hba|
			if hba["iscsiName"] == wwn_or_iscsi_name
				hba_id = hba["instanceId"]
			end
		end
		
		# Return id
		hba_id
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