# HBA custom type
Puppet::Type.newtype(:storagemanager_hba) do
	@doc = "Manage Server HBA creation, modification, and deletion."
	
	ensurable
	
	newparam(:allowmanual) do
		desc "Allows the HBA to be added to the Server even if the HBA is not visible on the Storage Center."
		# Allows blank string.
		newvalues(:true, :false, /^$/)
	end
	
	newparam(:name) do
		desc "The server name. Valid characters are a-z, 1-9, and underscore."
		isnamevar
		validate do |value|
			unless value =~ /^[\p{Word}\s\-]+$/u
				raise ArgumentError, "'%s' is not a valid initial server name." % value
			end
		end
	end
	
	newparam(:porttype) do
		desc "The port type. Valid values are Iscsi or FibreChannel, or blank value."
		newvalues(:Iscsi, :FibreChannel, /^$/)
	end
	
	newparam(:storagecenter) do
		desc "The id of the Storage Center on which to locate the server."
		validate do |value|
		value = value.to_s
			unless value =~ /^[0-9]*$/
				raise ArgumentError, "'%s' is not a valid Storage Center ID." % value
			end
		end
	end
	
	newparam(:wwn) do
		desc "The WWN. Valid characters are a-z, 1-9, and underscore; or can be a blank value."
		validate do |value|	
			unless value =~ /^[\p{Word},]*$|iqn.*/u
				raise ArgumentError, "'%s' is not a valid wwn or iSCSI name." % value
			end
		end
	end
end