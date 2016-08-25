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
# Provider for mapping custom type

require 'puppet/files/dsm_api_volume'
require 'puppet/files/dsm_api_server'

Puppet::Type.type(:dellstorageprovisioning_volume_map).provide(:mapping_provider) do
	@doc = 'Manage mapping/unmapping volumes.'
	
	# Class variables limit REST calls
	@vol_id = nil
	
	def create
		# Find server
		serv_id = DSMAPIServer.find_server(@resource[:servername], @resource[:storagecenter])
		if serv_id == nil
			raise ArgumentError, "Server '#{@resource[:servername]}' does not exist on Storage Center #{@resource[:storagecenter]}"
		end
		DSMAPIVolume.map_to_server(@vol_id, serv_id)
	end
	
	def destroy
		DSMAPIVolume.unmap(@vol_id)
	end
	
	# This method is always called first
	def exists?
		# Find volume
		@vol_id = DSMAPIVolume.find_volume(@resource[:name], @resource[:storagecenter])
		if @vol_id == nil
			raise ArgumentError, "Volume '#{@resource[:name]}' does not exist on Storage Center #{@resource[:storagecenter]}"
		end
		# Look for mapping
		DSMAPIVolume.check_for_map(@vol_id)
	end
end