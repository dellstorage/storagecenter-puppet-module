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
# This class contains methods relevant to finding objects on the Storage Center.
#
class DSMAPIFind
	
	attr_accessor :facts, :sc
	
	# This is a utility method to send a call to the DSM and handle the response
	def self.find(url, filter)
		resp = DSMAPIRequest.post(url, filter)
		DSMAPIRequest.check_resp(resp, url)
		list = JSON.parse(resp.body)
		list
	end
	
	# This method takes the name of an operating system and returns its id number
	def self.find_os(name)
		Puppet.debug "Inside find_os method of DSMAPIFind."
		
		# Create URL
		url = "#{$base_url}/StorageCenter/ScServerOperatingSystem/GetList"
		
		# Create filter
		filter = DSMAPIRequest.define_filter([["name", name, "Equals"]])
		
		# Make call
		os_list = find(url, filter)
		
		# Handle Response 
		id = find_in_response_array(os_list, "instanceId")
		if id
			Puppet.info "Found Operating System '#{name}' with id #{id}."
		else
			raise Puppet::Error, "Operating System '#{name}' is unsupported."
		end
		
		# Return ID
		id
	end
	
	# This method takes a server name and a storage center id and returns the id number of the server if it exists.
	def self.find_server(name, sc)
		Puppet.debug "Inside find_server method of DSMAPIFind."
		
		# Create URL
		url = "#{$base_url}/StorageCenter/ScServer/GetList"
		
		# Create filter
		filter = DSMAPIRequest.define_filter([
			["name", name, "Equals"],
			["scSerialNumber", sc.to_i, "Equals"],
			["serverFolderPath", $puppet_folder, "StartsWith"]
		])
		
		# Send call
		serv_list = find(url, filter)
		
		# Handle Response
		id = find_in_response_array(serv_list, "instanceId")
		if id
			Puppet.info "Server '#{name}' found with id #{id} on Storage Center #{sc}."
		else
			Puppet.info "Server '#{name}' not found on Storage Center #{sc}."
		end
		
		# Return ID
		id
	end
	
	# This method takes a volume name and storage center id and returns the volume id if it exists on the storage center.
	def self.find_volume(name, sc)
		Puppet.debug "Inside find_volume method of DSMAPIFind."
		
		# Create URL
		url = "#{$base_url}/StorageCenter/ScVolume/GetList"
		
		# Create filter
		filter = DSMAPIRequest.define_filter([
			["name", name, "Equals"],
			["scSerialNumber", sc.to_i, "Equals"],
			["volumeFolderPath", $puppet_folder, "StartsWith"]
		])
		
		# Send call
		vol_list = find(url, filter)
		
		# Handle Response
		id = find_in_response_array(vol_list, "instanceId")
		if id
			Puppet.info "Volume '#{name}' found with id #{id} on Storage Center #{sc}."
		else
			Puppet.info "Volume '#{name}' not found on Storage Center #{sc}."
		end
		
		# Return id
		id
	end
	
	# This method takes a server id number and a WWN or iSCSI name and determines whether the 
	# 	WWN or iSCSI name is present in the server's HBA list.
	def self.find_hba(serv_id, wwn_or_iscsi_name)
		Puppet.debug "Inside find_hba method of DSMAPIFind."
		
		# Create URL
		url = "#{$base_url}/StorageCenter/ScServer/#{serv_id}/HbaList"
		
		# Make call
		resp = DSMAPIRequest.get(url)
		
		# Handle Response
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
	
	# This method takes the response and a string
	# If the string is a key in the response hash the method will return its value
	def self.find_in_response_array(resp_array, str)
		Puppet.debug "Inside find_in_response_array method of DSMAPIFind."
		# Utility method to parse response
		subject = nil
		unless resp_array.kind_of?(Array)
			subject = resp_array[str]
			return subject
		end
		# Response is an array containing 1 item
		unless resp_array.empty?
			resp_array.each do |resp|
				unless resp.kind_of?(Array)
					subject = resp[str]
				end
			end
		end
		Puppet.debug "#{str} => #{subject}"
		subject
	end
end