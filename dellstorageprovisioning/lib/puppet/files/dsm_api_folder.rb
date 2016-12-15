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
# Class for regulating folder usage
# Contains methods relevant to folder creation/deletion.

require_relative 'dsm_api_find'
require_relative 'dsm_api_request'

class DSMAPIFolder

	# This method takes the name of a folder and a string denoting whether it is a "volume" or "server" as well as a storage center ID.
	# If a folder exists on the storage center of the correct type with the specified name, the method returns its ID.
	def self.get_folder_id(name, sc, type)
		Puppet.debug "Inside get_folder_id method of DSMAPIFolder."
		
		# Create URL
		url = "#{$base_url}/StorageCenter/Sc#{type.capitalize}Folder/GetList"
		
		# Create filter
		filter_request = [
			["name", name, "Equals"],
			["scSerialNumber", sc.to_i, "Equals"],
			["folderPath", $puppet_folder, "StartsWith"]]
		filter = DSMAPIRequest.define_filter(filter_request)
		
		# Make call
		folder_list = DSMAPIFind.find(url, filter)
		
		# Handle Response
		id = DSMAPIFind.find_in_response_array(folder_list, "instanceId")
		if id
			Puppet.info "Folder '#{name}' found with id #{id} on Storage Center #{sc}."
		else
			Puppet.info "Folder '#{name}' not found on Storage Center #{sc}."
		end
		
		# Return ID
		id
	end
	
	# This method takes a storage center ID and the type and retrieves the id number of the "Puppet Folder".
	# The name of the Puppet Folder is stored in the $puppet_folder variable.
	# If the Puppet Folder does not exist, the method creates the Puppet Folder on the Storage Center.
	def self.get_puppet_folder_id(sc, type)
		Puppet.debug "Inside get_puppet_folder_id method of DSMAPIFolder."
		
		# Create URL
		url = "#{$base_url}/StorageCenter/Sc#{type.capitalize}Folder/GetList"

		# Create filter
		filter_request = [["name", $puppet_folder, "Equals"], ["scSerialNumber", sc.to_i, "Equals"]]
		filter = DSMAPIRequest.define_filter(filter_request)

		# Make call
		folder_list = DSMAPIFind.find(url, filter)
		
		# Handle Response
		id = DSMAPIFind.find_in_response_array(folder_list, "instanceId")

		# If the puppet folder does not exist, must create one.
		unless id
			Puppet.notice "'#{$puppet_folder}' folder not found.\n Creating '#{$puppet_folder}' folder on Storage Center #{sc}."
			
			# Create URL
			url = "#{$base_url}/StorageCenter/Sc#{type.capitalize}Folder"
			
			# Create payload
			payload = {
				"Name" => $puppet_folder,
				"StorageCenter" => sc.to_i,
			}
			
			# Make call
			resp = DSMAPIRequest.post(url, payload)
			
			# Handle Response
			DSMAPIRequest.check_resp(resp, url)
			
			# Return ID
			id = JSON.parse(resp.body)["instanceId"]
		end
		id
	end
	
	# This method creates a folder
	def self.create_folder(fold_name, sc, type, parent)
		Puppet.debug "Inside create_folder method of DSMAPIFolder."
		
		# Create URL
		url = "#{$base_url}/StorageCenter/Sc#{type.capitalize}Folder"
		
		# Create payload
		payload = {
			"Name" => fold_name,
			"StorageCenter" => sc.to_i
		}
		
		# Get parent folder
		if parent == ''
			Puppet.debug "Parent Folder: #{$puppet_folder}"
			payload["parent"] = get_puppet_folder_id(sc, type)
		else
			Puppet.debug "Parent Folder: #{fold_name}"
			parent_id = get_folder_id(parent, sc, type)
			if parent_id == nil
				raise Puppet::Error, "Parent folder '#{parent}' does not exist on StorageCenter #{sc}."
			end
			payload["parent"] = parent_id
		end
		
		# Make Call
		resp = DSMAPIRequest.post(url, payload)
		
		# Handle Response
		DSMAPIRequest.check_resp(resp, url)
		
		# Return ID
		JSON.parse(resp.body)["instanceId"]
	end
	
	# This method deletes a folder
	def self.delete_folder(fold_id, type)
		Puppet.debug "Inside delete_folder method of DSMAPIFolder."
		
		# Create URL
		url = "#{$base_url}/StorageCenter/Sc#{type.capitalize}Folder/#{fold_id}"
		
		# Make call
		resp = DSMAPIRequest.delete(url)
		
		# Handle Response
		DSMAPIRequest.check_resp(resp, url)
	end
end