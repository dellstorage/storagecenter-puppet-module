# Provider for server cluster custom type

require 'puppet/files/dsm_api_server'

Puppet::Type.type(:storagemanager_servercluster).provide(:servercluster_provider) do
	@doc = 'Manage Server Cluster creation, modification, and deletion.'
	
	# Class variables reduce REST calls
	@cluster_id = nil
	
	# Method to create payload for server cluster creation
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
		
		payload["OperatingSystem"] = @resource[:operatingsystem]
		
		serverfolder = @resource[:serverfolder]
		if serverfolder == ''
			serverfolder = "puppet"
		end
		payload["ServerFolder"] = serverfolder
		
		payload
	end
	
	def create
		DSMAPIServer.create_servercluster(@resource[:name], @resource[:storagecenter], assign_payload)
	end
	
	def destroy
		DSMAPIServer.delete_server(@cluster_id)
	end
	
	# This method is always called first
	def exists?
		# Look for cluster
		@cluster_id = DSMAPIServer.find_server(@resource[:name], @resource[:storagecenter])
		if @cluster_id == nil
			return false
		else
			return true
		end
	end
end