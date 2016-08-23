# Provider for HBA custom type
#
require 'puppet/files/dsm_api_server'

Puppet::Type.type(:dellstorageprovisioning_hba).provide(:hba_provider) do
	@doc = "Manage Server HBA creation, modification, and deletion."
	
	# Class variables reduce REST calls
	@hba_id = nil
	@serv_id = nil
	
	# Method to create the payload for creation
	def assign_payload
		payload = {}
		
		if @resource[:allowmanual] == :true
			payload["AllowManual"] = true
		end
		payload
	end
	
	def create
		payload = assign_payload
		@hba_id = DSMAPIServer.add_HBA(@serv_id, @resource[:porttype], @resource[:wwn], payload)
	end
	
	def destroy
		DSMAPIServer.remove_HBA(@serv_id, @hba_id)
	end
	
	# This method is always called first
	def exists?
		# Find the server id
		@serv_id = DSMAPIServer.find_server(@resource[:name], @resource[:storagecenter])
		# Look for an HBA
		@hba_id = DSMAPIServer.find_hba(@serv_id, @resource[:wwn])
		if @hba_id == nil
			return false
		else
			return true
		end
	end
end