# Provider for volume custom type

require 'puppet/files/dsm_api_volume'

Puppet::Type.type(:dellstorageprovisioning_volume).provide(:volume_provider) do
  @doc = 'Manage Volume creation, modification and deletion.'
  
	# Class variables reduce REST calls
	@vol_id = nil

	# Method to create payload for volume creation
	def assign_payload
		payload = {}
		
		unless @resource[:datapagesize] == ''
			payload["DataPageSize"] = @resource[:datapagesize]
		end
		
		unless @resource[:datareductionprofile] == ''
			payload["DataReductionProfile"] = @resource[:datareductionprofile].to_i
		end
		
		unless @resource[:diskfolder] == ''
			payload["DiskFolder"] = @resource[:diskfolder].to_i
		end
		
		unless @resource[:groupqosprofile] == ''
			payload["GroupQosProfile"] = @resource[:groupqosprofile].to_i
		end
		
		unless @resource[:notes] == ''
			payload["Notes"] = @resource[:notes].to_s
		end
		
		unless @resource[:readcache] == ''
			payload["ReadCache"] =
				if @resource[:readcache] == :true
					true
				else
					false
				end
		end
		
		unless @resource[:redundancy] == ''
			payload["Redundancy"] = @resource[:redundancy]
		end
		
		unless @resource[:replayprofilelist] == ''
			payload["ReplayProfileList"] = @resource[:replayprofilelist]
		end
		
		unless @resource[:storageprofile] == ''
			payload["StorageProfile"] = @resource[:storageprofile].to_i
		end
		
		unless @resource[:storagetype] == ''
			payload["StorageProfile"] = @resource[:storageprofile].to_i
		end
		
		payload["VolumeFolder"] = @resource[:volumefolder]
		
		unless @resource[:volumeqosprofile] == ''
			payload["VolumeQosProfile"] = @resource[:volumeqosprofile].to_i
		end
		
		unless @resource[:writecache] = ''
			payload["WriteCache"] = 
				if @resource[:writecache] == :true
					true
				else
					false
				end
		end
		
		payload
	end
	
	def create
		payload = assign_payload
		DSMAPIVolume.create_volume(@resource[:name], @resource[:size], @resource[:storagecenter], payload)
	end
	
	def destroy
		DSMAPIVolume.delete_volume(@vol_id)
	end
	
	# This method is always called first
	def exists?
		# Look for volume
		@vol_id = DSMAPIVolume.find_volume(@resource[:name], @resource[:storagecenter])
		if @vol_id == nil
			return false
		else
			return true
		end
	end
end