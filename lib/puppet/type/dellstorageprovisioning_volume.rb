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
# Volume custom type
# This file presents a Volume and its properties to Puppet as an object that it can manage.
#
Puppet::Type.newtype(:dellstorageprovisioning_volume) do
	@doc = "Manage volume creation, modification and deletion."
  
	ensurable
	
	newparam(:datapagesize) do
		desc "The DataPage Size of the Redundant Storage Type to be used for the volume."
	end
	
	newparam(:datareductionprofile) do
		desc "Indicates the data reduction profile selected when creating a new volume."
	end
	
	newparam(:diskfolder) do
		desc "The disk folder to be used by the volume."
	end
	
	newparam(:groupqosprofile) do
		desc "When provided, the volume will be created with this group profile set."
	end

	newparam(:name) do
		desc "The volume name. Valid characters are a-z, 1-9, & underscore."
		isnamevar
	end
	
	newparam(:notes) do
		desc "Notes for the volume"
	end
	
	newparam(:readcache, :boolean => true) do
		desc "Enable readcache."
		newvalues(:true, :false)
		defaultto :true
	end
	
	newparam(:redundancy) do
		desc "The redundancy of the Storage Type to use for the volume."
	end
	
	newparam(:replayprofilelist) do
		desc "Replay Profiles to associate with the volume."
	end
	
	newparam(:size) do
		desc "Configured size for the volume."
	end
	
	newparam(:storagecenter) do
		desc "The id of the Storage Center on which to create the volume."
		validate do |value|
		value = value.to_s
			unless value =~ /^[0-9]*$/
				raise ArgumentError, "'%s' is not a valid Storage Center ID." % value
			end
		end
	end
	
	newparam(:storageprofile) do
		desc "Storage Profile for the volume."
	end
	
	newparam(:storagetype) do
		desc "Storage Type used by the Volume."
	end
	
	newparam(:volumefolder) do
		desc "The volume folder name. Valid characters are a-z, 1-9, & underscore."
	end
	
	newparam(:volumeqosprofile) do
		desc "When provided, the volume will be created with this profile set instead of the default profile."
	end
	
	newparam(:writecache, :boolean => true) do
		desc "Enable writecache."
		newvalues(:true, :false)
		defaultto :true
	end
end