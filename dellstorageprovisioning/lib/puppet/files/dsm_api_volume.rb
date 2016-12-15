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
# Class for managing ScVolumes.
# This class contains all the methods relating to Volumes
#
require 'json'
require_relative 'dsm_api_request'
require_relative 'dsm_api_folder'
require_relative 'dsm_api_find'

class DSMAPIVolume

	attr_accessor :vol_id
	
	# This method creates a volume.
	def self.create_volume(name, size, sc, payload)
		Puppet.debug "Inside create_volume method of DSMAPIVolume."
		
		# Required parameters
		payload["StorageCenter"] = sc.to_i
		payload["Name"]	= name
		payload["Size"] = size
		
		# Look up ScVolumeFolder InstanceId
		payload["VolumeFolder"] = assign_volume_folder(payload["VolumeFolder"], sc)
		
		# Create URL
		url = "#{$base_url}/StorageCenter/ScVolume"
		
		# Make call
		resp = DSMAPIRequest.post(url, payload)
		
		# Handle Response
		DSMAPIRequest.check_resp(resp, url)
		vol_id = JSON.parse(resp.body)["instanceId"]
		
		# Return ID
		vol_id
	end
	
	# This method maps a volume to a server
	def self.map_to_server(vol_id, serv_id, payload = {})
		Puppet.debug "Inside map_to_server method of DSMAPIVolume."
		
		# Do not map to a non-existant server
		if serv_id.nil?
			Puppet.info "Cannot map to Server: Server does not exist."
			return
		end
		
		# Create payload
		payload["Server"] = serv_id
		
		# Create URL
		url = "#{$base_url}/StorageCenter/ScVolume/" + vol_id + "/MapToServer"
		
		# Make call
		resp = DSMAPIRequest.post(url, payload)
		
		# Handle response
		DSMAPIRequest.check_resp(resp, url)
	end
	
	# This method unmaps a volume from a server
	def self.unmap(vol_id)
		Puppet.debug "Inside unmap method of DSMAPIVolume."
		
		# Do not unmap from a non-existant volume
		if vol_id.nil?
			Puppet.info "Cannot unmap from Server: Volume does not exist."
			return
		end
		
		# Create URL
		url = $base_url + "/StorageCenter/ScVolume/" + vol_id + "/Unmap"
		
		# Make call
		resp = DSMAPIRequest.post(url, {})
		
		# Handle Response
		DSMAPIRequest.check_resp(resp, url)
	end
	
	# This method deletes a volume
	def self.delete_volume(vol_id)
		Puppet.debug "Inside delete_volume method of DSMAPIVolume."
		
		# Create URL
		url = $base_url + "/StorageCenter/ScVolume/" + vol_id
		
		# Make call
		resp = DSMAPIRequest.delete(url)
		
		# Handle Response
		DSMAPIRequest.check_resp(resp, url)
	end
	
	# This method determines whether a volume is mapped
	def self.check_for_map(vol_id)
		Puppet.debug "Inside check_for_map method of DSMAPIVolume."
		
		# Create URL
		url = "#{$base_url}/StorageCenter/ScVolume/#{vol_id}"
		
		# Make call
		resp = DSMAPIRequest.get(url)
		
		# Handle Response
		DSMAPIRequest.check_resp(resp, url)
		resp_array = JSON.parse(resp.body)
		result = DSMAPIFind.find_in_response_array(resp_array, "mapped")
		
		# Return ID
		result
	end
	
	# This method retrieves a volume's id
	def self.find_volume(name, sc)
		# Make call
		vol_id = DSMAPIFind.find_volume(name, sc)
		
		# Return ID
		vol_id
	end
	
	# This method determines whether to use the Puppet folder or a specified folder and returns the appropriate id.
	def self.assign_volume_folder(folder_name, sc)
		# Determine whether to use Puppet folder
		if folder_name == ''
			Puppet.debug "Volume Folder: #{$puppet_folder}"
			# Make call
			fold_id = DSMAPIFolder.get_puppet_folder_id(sc, "volume")
		else
			Puppet.debug "Volume Folder: #{folder_name}"
			# Make call
			fold_id = DSMAPIFolder.get_folder_id(folder_name, sc, "volume")
			
			# Handle Response
			if fold_id == nil
				raise ArgumentError, "Volume folder '#{folder_name}' does not exist on Storage Center #{sc}."
			end
			
			Puppet.info "Found Volume Folder '#{folder_name}' with ID #{fold_id} on Storage Center #{sc}."
		end
		# Return ID
		fold_id
	end
end