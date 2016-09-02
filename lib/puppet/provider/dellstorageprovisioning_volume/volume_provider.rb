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
# Provider for volume custom type
# The provider tells Puppet what to do with the attributes of a defined Volume
#
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
			Puppet.debug "DataPage Size: #{@resource[:datapagesize]}"
		end
		
		unless @resource[:datareductionprofile] == ''
			payload["DataReductionProfile"] = @resource[:datareductionprofile]
			Puppet.debug "Data Reduction Profile: #{@resource[:datareductionprofile]}"
		end
		
		unless @resource[:diskfolder] == ''
			payload["DiskFolder"] = @resource[:diskfolder]
			Puppet.debug "Disk Folder: #{@resource[:diskfolder]}"
		end
		
		unless @resource[:groupqosprofile] == ''
			payload["GroupQosProfile"] = @resource[:groupqosprofile]
			Puppet.debug "Group QOS Profile: #{@resource[:groupqosprofile]}"
		end
		
		unless @resource[:notes] == ''
			payload["Notes"] = @resource[:notes].to_s
			Puppet.debug "Notes: #{@resource[:notes]}"
		end
		
		unless @resource[:readcache] == ''
			payload["ReadCache"] =
				if @resource[:readcache] == :true
					true
				else
					false
				end
			Puppet.debug "Reacache: #{@resource[:readcache]}"
		end
		
		unless @resource[:redundancy] == ''
			payload["Redundancy"] = @resource[:redundancy]
			Puppet.debug "Redundancy: #{@resource[:redundancy]}"
		end
		
		unless @resource[:replayprofilelist] == ''
			payload["ReplayProfileList"] = @resource[:replayprofilelist]
			Puppet.debug "Replay Profile List: #{@resource[:replayprofilelist]}"
		end
		
		unless @resource[:storageprofile] == ''
			payload["StorageProfile"] = @resource[:storageprofile]
			Puppet.debug "Storage Profile: #{@resource[:storageprofile]}"
		end
		
		unless @resource[:storagetype] == ''
			payload["StorageType"] = @resource[:storagetype]
			Puppet.debug "Storage Type: #{@resource[:storagetype]}"
		end
		
		payload["VolumeFolder"] = @resource[:volumefolder]
		
		unless @resource[:volumeqosprofile] == ''
			payload["VolumeQosProfile"] = @resource[:volumeqosprofile]
			Puppet.debug "Volume QOS Profile: #{@resource[:volumeqosprofile]}"
		end
		
		if @resource[:writecache] = :false
			payload["WriteCache"] = false
			Puppet.debug "Writecache: false"
		else
			payload["WriteCache"] = true
		end
		
		payload
	end
	
	# Creating volume
	def create
		Puppet.info "Creating volume #{@resource[:name]}."
		Puppet.debug "Storage Center: #{@resource[:storagecenter]}"
		Puppet.debug "Size: #{@resource[:size]}"
		payload = assign_payload
		DSMAPIVolume.create_volume(@resource[:name], @resource[:size], @resource[:storagecenter], payload)
	end
	
	# Deleting volume
	def destroy
		Puppet.info "Deleting Volume #{@resource[:name]}."
		DSMAPIVolume.delete_volume(@vol_id)
	end
	
	# Determining whether volume exists
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