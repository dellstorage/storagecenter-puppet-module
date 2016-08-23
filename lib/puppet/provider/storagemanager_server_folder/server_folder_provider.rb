# Provider for server folder custom type

require 'puppet/files/dsm_api_folder'

Puppet::Type.type(:storagemanager_server_folder).provide(:server_folder_provider) do
	@doc = 'Manage creation and deletion of server folders.'
	
	# Class variables reduce REST calls
	@fold_id = nil
	
	def create
		@fold_id = DSMAPIFolder.create_folder(@resource[:name], @resource[:storagecenter], "server", @resource[:parent])
	end
	
	def destroy
		DSMAPIFolder.delete_folder(@fold_id, "server")
	end
	
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