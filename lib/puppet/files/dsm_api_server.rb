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

class DSMAPIServer
	attr_accessor :serv_id
	
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
			payload["OperatingSystem"] = find_os(payload["OperatingSystem"])
		end

		# Make call to create a new server
		unless url
			url = "#{$base_url}/StorageCenter/ScPhysicalServer"
		end
		
		# Handle response
		resp = DSMAPIRequest.post(url, payload)
		DSMAPIRequest.check_resp(resp, url)
		
		# Return ScServer InstanceId
		serv_id = JSON.parse(resp.body)["instanceId"]
		serv_id 
	end
	
	def self.create_servercluster(name, sc, payload)
		Puppet.debug "Inside create_servercluster method of DSMAPIServer."
		url = "#{$base_url}/StorageCenter/ScServerCluster"
		create_server(name, sc, payload, url)
	end
	
	def self.add_HBA(serv_id, port_type, iscsi_name, payload)
		Puppet.debug "Inside add_HBA method of DSMAPIServer."

		# Don't add an HBA to a non-existant server
		if serv_id == nil
			raise "Server does not exist."
		end
		
		#make call to add hba
		url = "#{$base_url}/StorageCenter/ScPhysicalServer/#{serv_id}/AddHba"
		
		# Required parameters
		payload["HbaPortType"] = port_type
		payload["WwnOrIscsiName"] = iscsi_name
		
		# Handle response
		resp = DSMAPIRequest.post(url, payload)
		DSMAPIRequest.check_resp(resp, url)
		
		# Return HBA id
		hba_id = JSON.parse(resp.body)["instanceId"]
		hba_id
	end
	
	def self.remove_HBA(serv_id, hba_id)
		Puppet.debug "Inside remove_HBA method of DSMAPIServer."

		# Don't remove an HBA from a non-existant server
		unless serv_id
			return "server does not exist"
		end
		
		# Don't remove a non-existant HBA
		if hba_id == nil
			return false
		end
		
		# Make call to remove HBA
		url = "#{$base_url}/StorageCenter/ScPhysicalServer/#{serv_id}/RemoveHba"
		
		# Create payload
		payload = {"ServerHba" => hba_id}
		
		# Handle response
		resp = DSMAPIRequest.post(url, payload)
		DSMAPIRequest.check_resp(resp, url)
	end
	
	def self.delete_server(serv_id)
		Puppet.debug("Inside delete_server method of DSMAPIServer.")
		
		# Make call to delete server
		url = "#{$base_url}/StorageCenter/ScServer/#{serv_id}"
		
		# Handle response
		resp = DSMAPIRequest.delete(url)
		DSMAPIRequest.check_resp(resp, url)
	end
	
	def self.find_server(name, sc)
		# Make call to find server
		serv_id = DSMAPIFind.find_server(name, sc)
		
		# Return id
		serv_id
	end
	
	def self.find_hba(serv_id, wwn_or_iscsi_name)
		Puppet.debug "Inside find_hba method of DSMAPIServer."
		
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
	
	def self.find_os(name)
		Puppet.debug "Inside find_os method of DSMAPIServer."
		
		# Make call to find OS
		url = "#{$base_url}/StorageCenter/ScServerOperatingSystem/GetList"
		filter = DSMAPIRequest.define_filter([["name", name, "Equals"]])
		os_list = DSMAPIFind.find(url, filter)
		
		# Handle Response 
		id = DSMAPIFind.find_in_response_array(os_list, "instanceId")
		if id
			Puppet.info "Found Operating System '#{name}' with id #{id}."
		else
			raise ArgumentError, "Operating System '#{name}' is unsupported."
		end
		id
	end
	
	def self.assign_parent(parent_name, sc, payload)
		parent = DSMAPIServer.find_server(parent_name, sc)
		if parent == nil
			raise ArgumentError, "Parent '#{parent_name}' does not exist on StorageCenter #{sc}."
		end
		parent
	end
	
	def self.assign_server_folder(folder_name, sc)
		if folder_name == ''
			fold_id = DSMAPIFolder.get_puppet_folder_id(sc, "server")
		else
			fold_id = DSMAPIFolder.get_folder_id(folder_name, sc, "server")
			if fold_id == nil
				raise ArgumentError, "Server Folder '#{folder_name}' does not exist on StorageCenter #{sc}."
			end
		end
		fold_id
	end
end