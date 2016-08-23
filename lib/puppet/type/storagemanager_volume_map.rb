# Mapping custom type

Puppet::Type.newtype(:dellstorageprovisioning_volume_map) do
	@doc = "Manage Mapping and Unmapping Volumes."
	
	ensurable
	
	newparam(:name)	do
		desc 'The name of the volume to be mapped with the server.'
		desc 'Valid characters are a-z, 1-9, and underscore.'
		isnamevar
		validate do |value|
			unless value =~ /^[\p{Word}\s\-]+$/u
				raise ArgumentError, "'%s' is not a valid volume name." % value
			end
		end
	end
	
	newparam(:servername) do
		desc 'The name of the server with which to map the volume.'
		validate do |value|
			unless value =~ /^[\p{Word}\s\-]+$|^$/u
				raise ArgumentError, "'%s' is not a valid server name." % value
			end
		end
	end
	
	newparam(:storagecenter) do
		desc 'The id of the Storage Center on which the volume and server are located.'
		validate do |value|
		value = value.to_s
			unless value =~ /^[0-9]*$/
				raise ArgumentError, "'%s' is not a valid Storage Center ID." % value
			end
		end
	end
end