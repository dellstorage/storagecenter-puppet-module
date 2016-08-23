# Volume custom type
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
	
	newparam(:GroupQosProfile) do
		desc "When provided, the volume will be created with this group profile set."
	end

	newparam(:name) do
		desc "The volume name. Valid characters are a-z, 1-9, & underscore."
		isnamevar
		validate do |value|
			unless value =~ /^[\p{Word}\s\-]+$/u
				raise ArgumentError, "'%s' is not a valid initial volume name." % value
			end
		end
	end
	
	newparam(:notes) do
		desc "Notes for the volume"
	end
	
	newparam(:readcache, :boolean => true) do
		desc "Enable readcache."
		newvalues(:true, :false, /^$/)
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
		validate do |value|
			unless value =~ /^\d+(KB|MB|GB|TB$)|^$/
				raise ArgumentError, "'%s' is not a valid initial volume size." % value
			end
		end
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
		validate do |value|
			unless value =~ /^\w|^$/
				raise ArgumentError, "'%s' is not a valid initial volume folder name." % value
			end
		end
	end
	
	newparam(:volumeqosprofile) do
		desc "When provided, the volume will be created with this profile set instead of the default profile."
	end
	
	newparam(:writecache, :boolean => true) do
		desc "Enable writecache."
		newvalues(:true, :false, /^$/)
		defaultto :true
	end
end