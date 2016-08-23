# Provider for server custom type
require 'puppet/files/dsm_api_server'

Puppet::Type.type(:dellstorageprovisioning_server).provide(:server_provider) do
	@doc = 'Manage server creation, modification, and deletion.'
	
	# Class variables decrease REST calls
	@serv_id = nil
	
	#Method to create payload for creation
	def assign_payload
		payload = {}
		
		if @resource[:alertonconnectivity] == :true
			payload["AlertOnConnectivity"] = true
		end
		
		if @resource[:alertonpartialconnectivity] == :true
			payload["AlertOnPartialConnectivity"] = true
		end
		
		unless @resource[:notes] == ''
			payload["Notes"] = @resource[:notes]
		end
		
		unless @resource[:operatingsystem] == ''
			payload["OperatingSystem"] = @resource[:operatingsystem]
		end
		
		serverfolder = @resource[:serverfolder]
		if serverfolder == ''
			serverfolder = "puppet"
		end
		payload["ServerFolder"] = serverfolder
		
		unless @resource[:parent] == ''
			payload["Parent"] = @resource[:parent]
		end
		
		payload
	end
	
	def create
		DSMAPIServer.create_server(@resource[:name], @resource[:storagecenter], assign_payload)
	end
	
	def destroy
		DSMAPIServer.delete_server(@serv_id)
	end
	
	# This method is always called first
	def exists?
		# Look for server
		@serv_id = DSMAPIServer.find_server(@resource[:name], @resource[:storagecenter])
		if @serv_id == nil
			return false
		else
			return true
		end
	end
end