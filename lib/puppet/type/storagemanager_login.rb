# Login custom type

Puppet::Type.newtype(:storagemanager_login) do
	@doc = "Manage logging into Dell Storage Manager."
	
	ensurable
	
	newparam(:name) do
		desc "The ip address of the DSM."
		validate do |value|
			unless value =~ /^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$/
				raise ArgumentError, "'%s' is not a valid ip address." %value
			end
		end
		isnamevar
	end
	
	newparam(:password) do
		desc "The passsword to log into the DSM."
	end
	
	newparam(:username) do
		desc "The username to log into the DSM."
	end
end