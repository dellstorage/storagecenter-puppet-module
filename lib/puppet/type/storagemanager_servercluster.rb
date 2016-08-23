# Server Cluster custom type

Puppet::Type.newtype(:storagemanager_servercluster) do
	@doc = "Manage ServerCluster creation, modification, and deletion."
	
	ensurable
	
	newparam(:alertonconnectivity) do
		desc "Alert if the connectivity of the server goes down or is degraded."
		newvalues(:true, :false)
		defaultto(:true)
	end
	
	newparam(:alertonpartialconnectivity) do
		desc "Indicates whether partial connectivity alerts should be generated for the server cluster."
		newvalues(:true, :false)
		defaultto(:true)
	end
	
	newparam(:name) do
		desc "The server name. Valid characters are a-z, 1-9, and underscore."
		isnamevar
		validate do |value|
			unless value =~ /^[\p{Word}\s\-]+$/u 
				raise ArgumentError, "'%s' is not a valid Server Cluster name." % value
			end
		end
	end
	
	newparam(:notes) do
		desc "Notes for the Server Cluster."
	end
	
	newparam(:operatingsystem) do
		desc "The Operating System of the Server Cluster."
		validate do |value|
			if value =~ /^$/
				raise ArgumentError, "operating_system is a required parameter."
			end
		end
	end
	
	newparam(:serverfolder) do
		desc "Parent Folder for the Server Cluster."
		validate do |value|
			unless value =~ /^\w*$|^$/
				raise ArgumentError, "'%s' is not a valid Server Folder name." %value
			end
		end
	end
	
	newparam(:storagecenter) do
		desc "Storage Center where the object will be created."
		validate do |value|
			value = value.to_s
			unless value =~ /^[0-9]*$/
				raise ArgumentError, "%s is not a valid Storage Center ID." % value
			end
		end
	end
end