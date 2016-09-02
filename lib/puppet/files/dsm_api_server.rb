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
# This class deals with all functions relating to Servers.
#
require 'json'
require_relative 'dsm_api_request'
require_relative 'dsm_api_folder'
require_relative 'dsm_api_find'

class DSMAPIServer
	attr_accessor :serv_id
	
	# This method creates a server
	def self.create_server(name, sc, payload, url = nil)
		Puppet.debug "Inside create_server method of DSMAPIServer."
		
		# Required parameters
		payload["Name"] = name
		payload["StorageCenter"] = sc.to_i
		
		# Look up ScServerFolder InstanceId
		payload["ServerFolder"] = assign_server_folder(payload["ServerFolder"], sc)
		
		# Look up Parent InstanceId
		if payload["Parent"]
			payload["Parent"] = assign_parent(payload["Parent"], sc, payload)
		end
		
		# Look up Operating System InstanceId
		if payload["OperatingSystem"]
			payload["OperatingSystem"] = DSMAPIFind.find_os(payload["OperatingSystem"])
		end

		# Create URL
		unless url
			url = "#{$base_url}/StorageCenter/ScPhysicalServer"
		end
		
		# Make call
		resp = DSMAPIRequest.post(url, payload)
		
		# Handle response
		DSMAPIRequest.check_resp(resp, url)
		serv_id = JSON.parse(resp.body)["instanceId"]
		
		# Return ID
		serv_id 
	end
	
	# This method creates a server cluster
	def self.create_servercluster(name, sc, payload)
		Puppet.debug "Inside create_servercluster method of DSMAPIServer."
		
		# Create URL
		url = "#{$base_url}/StorageCenter/ScServerCluster"
		
		# Forward URL to create_server method
		create_server(name, sc, payload, url)
	end
	
	# This method adds an HBA to a server
	def self.add_HBA(serv_id, port_type, iscsi_name, payload)
		Puppet.debug "Inside add_HBA method of DSMAPIServer."

		# Don't add an HBA to a non-existant server
		if serv_id == nil
			raise Puppet::Error, "Cannot add HBA '#{iscsi_name}': Server does not exist."
		end
		
		# Create URL
		url = "#{$base_url}/StorageCenter/ScPhysicalServer/#{serv_id}/AddHba"
		
		# Create payload
		payload["HbaPortType"] = port_type
		payload["WwnOrIscsiName"] = iscsi_name
		
		# Make call
		resp = DSMAPIRequest.post(url, payload)
		
		# Handle Response
		DSMAPIRequest.check_resp(resp, url)
		hba_id = JSON.parse(resp.body)["instanceId"]
		
		# Return ID
		hba_id
	end
	
	# This method removes an HBA from a server
	def self.remove_HBA(serv_id, hba_id)
		Puppet.debug "Inside remove_HBA method of DSMAPIServer."

		# Don't remove an HBA from a non-existant server
		unless serv_id
			Puppet.info "Cannot remove HBA: Server does not exist."
			return
		end
		
		# Don't remove a non-existant HBA
		if hba_id == nil
			Puppet.info "Cannot remove HBA: HBA does not exist."
			return
		end
		
		# Create URL
		url = "#{$base_url}/StorageCenter/ScPhysicalServer/#{serv_id}/RemoveHba"
		
		# Create payload
		payload = {"ServerHba" => hba_id}
		
		# Make call
		resp = DSMAPIRequest.post(url, payload)
		
		# Handle response
		DSMAPIRequest.check_resp(resp, url)
	end
	
	# This method deletes a server
	def self.delete_server(serv_id)
		Puppet.debug("Inside delete_server method of DSMAPIServer.")
		
		# Create URL
		url = "#{$base_url}/StorageCenter/ScServer/#{serv_id}"
		
		# Make call
		resp = DSMAPIRequest.delete(url)
		
		# Handle response
		DSMAPIRequest.check_resp(resp, url)
	end
	
	# This method asks the find class to find the server
	def self.find_server(name, sc)
		# Make call 
		serv_id = DSMAPIFind.find_server(name, sc)
		
		# Return ID
		serv_id
	end
	
	# This method asks the find class to find the HBA
	def self.find_hba(serv_id, wwn_or_iscsi_name)
		# Make call
		hba_id = DSMAPIFind.find_hba(serv_id, wwn_or_iscsi_name)
		
		# Return ID
		hba_id
	end
	
	# This method retrieves the server cluster ID and raises an error if it is not found.
	def self.assign_parent(parent_name, sc, payload)
		
		# Make call
		parent = DSMAPIServer.find_server(parent_name, sc)
		
		# Handle response
		if parent == nil
			raise Puppet::Error, "Parent '#{parent_name}' does not exist on Storage Center #{sc}."
		end
		
		# Return ID
		parent
	end
	
	# This method determines whether to use the Puppet Folder or another specified folder, and retrieves the appropriate id.
	def self.assign_server_folder(folder_name, sc)
		if folder_name == ''
			Puppet.debug "Server Folder: #{$puppet_folder}"
			# Make call
			fold_id = DSMAPIFolder.get_puppet_folder_id(sc, "server")
		else
			Puppet.debug "Server Folder: #{folder_name}"
			# Make call
			fold_id = DSMAPIFolder.get_folder_id(folder_name, sc, "server")
			
			# Handle response
			if fold_id == nil
				raise Puppet::Error, "Server Folder '#{folder_name}' does not exist on Storage Center #{sc}."
			end
			
			Puppet.info "Found Server Folder '#{folder_name}' with ID #{fold_id} on Storage Center #{sc}."
		end
		
		# Return ID
		fold_id
	end
end