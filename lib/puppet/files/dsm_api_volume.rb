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
require 'json'
require_relative 'dsm_api_request'
require_relative 'dsm_api_folder'
require_relative 'dsm_api_find'

class DSMAPIVolume

	attr_accessor :vol_id
	
	def self.create_volume(name, size, sc, payload)
		Puppet.debug "Inside create_volume method of DSMAPIVolume."
		
		# Required parameters
		payload["StorageCenter"] = sc.to_i
		payload["Name"]	= name
		payload["Size"] = size
		
		# Look up ScVolumeFolder InstanceId
		payload["VolumeFolder"] = assign_volume_folder(payload["VolumeFolder"], sc)
		
		# Make https call to create new volume
		url = "#{$base_url}/StorageCenter/ScVolume"
		
		# Handle response
		resp = DSMAPIRequest.post(url, payload)
		DSMAPIRequest.check_resp(resp, url)
		
		# Retrieve ScVolume InstanceId
		vol_id = JSON.parse(resp.body)["instanceId"]
		vol_id
	end
	
	def self.map_to_server(vol_id, serv_id, payload = {})
		Puppet.debug("Inside map_to_server method of DSMAPIVolume.")
		
		# Do not map to a non-existant server
		if serv_id.nil?
			return
		end
		
		payload["Server"] = serv_id
		
		# Map to server
		url = "#{$base_url}/StorageCenter/ScVolume/" + vol_id + "/MapToServer"
		
		# Handle response
		resp = DSMAPIRequest.post(url, payload)
		DSMAPIRequest.check_resp(resp, url)
	end
	
	def self.unmap(vol_id)
		Puppet.debug "Inside unmap method of DSMAPIVolume."
		
		# Do not unmap from a non-existant volume
		if vol_id.nil?
			return
		end
		
		# Unmap from server
		url = $base_url + "/StorageCenter/ScVolume/" + vol_id + "/Unmap"
		
		# Handle response
		resp = DSMAPIRequest.post(url, {})
		DSMAPIRequest.check_resp(resp, url)
	end
	
	def self.delete_volume(vol_id)
		Puppet.debug "Inside delete_volume method of DSMAPIVolume."
		
		url = $base_url + "/StorageCenter/ScVolume/" + vol_id
		
		# Handle Response
		resp = DSMAPIRequest.delete(url)
		DSMAPIRequest.check_resp(resp, url)
	end
	
	def self.check_for_map(vol_id)
		Puppet.debug "Inside check_for_map method of DSMAPIVolume."
		
		url = "#{$base_url}/StorageCenter/ScVolume/#{vol_id}"
		
		# Handle response
		resp = DSMAPIRequest.get(url)
		DSMAPIRequest.check_resp(resp, url)
		
		# Retrieve mapping indication
		resp_array = JSON.parse(resp.body)
		result = DSMAPIFind.find_in_response_array(resp_array, "mapped")
		
		result
	end
	
	def self.find_volume(name, sc)
		vol_id = DSMAPIFind.find_volume(name, sc)
		vol_id
	end
	
	def self.assign_volume_folder(folder_name, sc)
		if folder_name == ''
			fold_id = DSMAPIFolder.get_puppet_folder_id(sc, "volume")
		else
			fold_id = DSMAPIFolder.get_folder_id(folder_name, sc, "volume")
			if fold_id == nil
				raise ArgumentError, "Volume folder '#{folder_name}' does not exist on StorageCenter #{sc}."
			end
		end
		fold_id
	end
end