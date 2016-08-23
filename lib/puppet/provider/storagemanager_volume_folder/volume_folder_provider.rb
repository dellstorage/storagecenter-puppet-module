# Provider for volume folder custom type

require 'puppet/files/dsm_api_folder'

Puppet::Type.type(:storagemanager_volume_folder).provide(:volume_folder_provider) do
	@doc = 'Manage creation and deletion of volume folders.'
	
	# Class variables reduce REST calls
	@fold_id = nil
	
	def create
		@fold_id = DSMAPIFolder.create_folder(@resource[:name], @resource[:storagecenter], "volume", @resource[:parent])
	end
	
	def destroy
		DSMAPIFolder.delete_folder(@fold_id, "volume")
	end
	
	# This method is always called first
	def exists?
		# Look for folder
		@fold_id = DSMAPIFolder.get_folder_id(@resource[:name], @resource[:storagecenter], "volume")
		if @fold_id == nil
			return false
		else
			return true
		end
	end
end