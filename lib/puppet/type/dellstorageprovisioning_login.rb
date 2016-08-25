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
# Login custom type

Puppet::Type.newtype(:dellstorageprovisioning_login) do
	@doc = "Manage logging into Dell Storage Manager."
	
	ensurable
	
	newparam(:port_number) do
		desc "The port number on which to connect to the DSM."
		validate do |value|
			value = value.to_s
			unless value =~ /^[0-9]+$/
				raise ArgumentError, "'%s' is not a valid port number." %value
			end
		end
	end
	
	newparam(:main_folder_name) do
		desc "The name of the top-level folder in which Puppet may work."
		validate do |value|
			unless value =~ /^[\p{Word}\s\-]+$/u
				raise ArgumentError, "'%s' is not a valid top-level folder name." %value
			end
		end
	end
	
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