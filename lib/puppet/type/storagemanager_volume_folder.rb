# Volume folder custom type

Puppet::Type.newtype(:storagemanager_volume_folder) do
	@doc = "Manage creating and deleting volume and server folders."
	
	ensurable
	
	newparam(:name) do
		desc "The name of the folder to be created."
		isnamevar
		validate do |value|
			unless value =~ /^[\p{Word}\s\-]+$/u
				raise ArgumentError, "'%s' is not a valid folder name." % value
			end
		end
	end
	
	newparam(:notes) do
		desc "Notes for the folder."
	end
	
	newparam(:parent) do
		desc "Name of a parent folder."
		validate do |value|
			unless value =~ /^[\p{Word}\s\-]+$|^$/u
				raise ArgumentError, "'%s' is not a valid parent folder name." % value
			end
		end
	end
	
	newparam(:storagecenter) do
		desc "The id of the Storage Center on which to create the folder."
		validate do |value|
		value = value.to_s
			unless value =~ /^[0-9]*$/
				raise ArgumentError, "'%s' is not a valid Storage Center ID." % value
			end
		end
	end
end