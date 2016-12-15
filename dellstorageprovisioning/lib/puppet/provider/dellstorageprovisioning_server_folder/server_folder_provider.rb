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
# Provider for server folder custom type
# The provider tells Puppet what to do with the Server Folder's defined attributes.
#
require 'puppet/files/dsm_api_folder'

Puppet::Type.type(:dellstorageprovisioning_server_folder).provide(:server_folder_provider) do
	@doc = 'Manage creation and deletion of server folders.'
	
	# Class variables reduce REST calls
	@fold_id = nil
	
	# Creating folder
	def create
		Puppet.info "Creating Server Folder '#{@resource[:name]}'."
		Puppet.debug "Storage Center: #{@resource[:storagecenter]}"
		@fold_id = DSMAPIFolder.create_folder(@resource[:name], @resource[:storagecenter], "server", @resource[:parent])
	end
	
	# Deleting folder
	def destroy
		Puppet.info "Deleting Server Folder '#{@resource[:name]}'."
		DSMAPIFolder.delete_folder(@fold_id, "server")
	end
	
	# Checking whether folder exists
	# This method is always called first
	def exists?
		# Check for folder
		@fold_id = DSMAPIFolder.get_folder_id(@resource[:name], @resource[:storagecenter], "server")
		if @fold_id == nil
			return false
		else
			return true
		end
	end
end