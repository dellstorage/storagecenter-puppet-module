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
# Provider for server cluster custom type
# The provider tells Puppet what to do with the Cluster's defined attributes.
# After this point, the program no longer distinguishes between Servers and Server Clusters.
#
require 'puppet/files/dsm_api_server'

Puppet::Type.type(:dellstorageprovisioning_servercluster).provide(:servercluster_provider) do
	@doc = 'Manage Server Cluster creation, modification, and deletion.'
	
	# Class variables reduce REST calls
	@cluster_id = nil
	
	# Method to create payload for server cluster creation
	def assign_payload
		payload = {}
		
		if @resource[:alertonconnectivity] == :true
			Puppet.debug "Alert On Connectivity: #{@resource[:alertonconnectivity]}"
			payload["AlertOnConnectivity"] = true
		end
		
		if @resource[:alertonpartialconnectivity] == :true
			Puppet.debug "Alert On Partial Connectivity: #{@resource[:alertonpartialconnectivity]}"
			payload["AlertOnPartialConnectivity"] = true
		end
	
		unless @resource[:notes] == ''
			Puppet.debug "Notes: #{@resource[:notes]}"
			payload["Notes"] = @resource[:notes]
		end
		
		payload["OperatingSystem"] = @resource[:operatingsystem]
		Puppet.debug "Operating System: #{@resource[:operatingsystem]}"
		
		payload["ServerFolder"] = @resource[:serverfolder]
		
		payload
	end
	
	# Creating server cluster
	def create
		Puppet.info "Creating Server Cluster '#{@resource[:name]}'."
		Puppet.debug "Storage Center: #{@resource[:storagecenter]}"
		DSMAPIServer.create_servercluster(@resource[:name], @resource[:storagecenter], assign_payload)
	end
	
	# Deleting server cluster
	def destroy
		Puppet.info "Deleting Server Cluster '#{@resource[:name]}'."
		DSMAPIServer.delete_server(@cluster_id)
	end
	
	# Determining whether server cluster exists
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