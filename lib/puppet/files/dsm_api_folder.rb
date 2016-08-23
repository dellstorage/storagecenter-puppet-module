# Class for regulating folder usage

require_relative 'dsm_api_find'
require_relative 'dsm_api_request'

class DSMAPIFolder


	def self.get_folder_id(name, sc, type)
		Puppet.debug "Inside get_folder_id method of DSMAPIFolder."
		
		# Set URL
		url = "#{$base_url}/StorageCenter/Sc#{type.capitalize}Folder/GetList"
		
		# Create filter
		filter_request = [
			["name", name, "Equals"],
			["scSerialNumber", sc.to_i, "Equals"],
			["folderPath", $puppet_folder, "StartsWith"]]
		filter = DSMAPIRequest.define_filter(filter_request)
		
		# Handle response
		folder_list = DSMAPIFind.find(url, filter)
		id = DSMAPIFind.find_in_response_array(folder_list, "instanceId")
		if id
			Puppet.info "Folder '#{name}' found with id #{id}."
		else
			Puppet.info "Folder '#{name}' not found."
		end
		id
	end
	
	def self.get_puppet_folder_id(sc, type)
		Puppet.debug "Inside get_puppet_folder_id method of DSMAPIFolder."
		
		# Set URL
		url = "#{$base_url}/StorageCenter/Sc#{type.capitalize}Folder/GetList"

		# Create filter
		filter_request = [["name", $puppet_folder, "Equals"], ["scSerialNumber", sc.to_i, "Equals"]]
		filter = DSMAPIRequest.define_filter(filter_request)

		# Handle Response
		folder_list = DSMAPIFind.find(url, filter)
		
		id = DSMAPIFind.find_in_response_array(folder_list, "instanceId")

		# If the puppet folder does not exist, must create one.
		unless id
			Puppet.info "'#{$puppet_folder}' folder not found.\n Creating '#{$puppet_folder}' folder on Storage Center #{sc}."
			
			# Creating puppet folder
			url = "#{$base_url}/StorageCenter/Sc#{type.capitalize}Folder"
			payload = {
				"Name" => $puppet_folder,
				"StorageCenter" => sc.to_i,
			}
			# Handle response
			resp = DSMAPIRequest.post(url, payload)
			DSMAPIRequest.check_resp(resp, url)
			
			# Return id
			id = JSON.parse(resp.body)["instanceId"]
		end
		id
	end
	
	def self.create_folder(fold_name, sc, type, parent)
		Puppet.debug "Inside create_folder method of DSMAPIFolder."
		
		# Set URL
		url = "#{$base_url}/StorageCenter/Sc#{type.capitalize}Folder"
		
		# Create payload
		payload = {
			"Name" => fold_name,
			"StorageCenter" => sc.to_i
		}
		
		# Get parent folder
		if parent == ''
			payload["parent"] = get_puppet_folder_id(sc, type)
		else
			parent_id = get_folder_id(parent, sc, type)
			if parent_id == nil
				raise ArgumentError, "Parent folder '#{fold_name}' does not exist on StorageCenter #{sc}"
			end
			payload["parent"] = parent_id
		end
		
		# Handle response
		resp = DSMAPIRequest.post(url, payload)
		DSMAPIRequest.check_resp(resp, url)
		
		# Return id
		JSON.parse(resp.body)["instanceId"]
	end
	
	def self.delete_folder(fold_id, type)
		Puppet.debug "Inside delete_folder method of DSMAPIFolder."
		
		# Set URL
		url = "#{$base_url}/StorageCenter/Sc#{type.capitalize}Folder/#{fold_id}"
		
		# Handle response
		resp = DSMAPIRequest.delete(url)
		DSMAPIRequest.check_resp(resp, url)
	end
end