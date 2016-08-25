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
# Server custom type

Puppet::Type.newtype(:dellstorageprovisioning_server) do
	@doc = "Manage Server creation, modification, and deletion."
	
	ensurable

	newparam(:alertonconnectivity) do
		desc "Alert if the connectivity of the server goes down or degraded."
		newvalues(:true, :false)
		defaultto(:true)
	end
	
	newparam(:alertonpartialconnectivity) do
		desc "Indicates whether partial connectivity alerts should be generated for the server."
		newvalues(:true, :false)
		defaultto(:true)
	end
	
	newparam(:name) do
		desc "The server name. Valid characters are a-z, 1-9, & underscore."
		isnamevar
		validate do |value|
			unless value =~ /^[\p{Word}\s\-]+$/u
				raise ArgumentError, "'%s' is not a valid initial server name." % value
			end
		end
	end
	
	newparam(:notes) do
		desc "Notes for the server."
	end
	
	newparam(:operatingsystem) do
		desc "The Operating System of the Server."
	end
	
	newparam(:parent) do
		desc "Parent Server for this Server."
	end
	
	newparam(:serverfolder) do
		desc "The server folder name. Valid characters are a-z, 1-9, and underscore."
	end
	
	newparam(:storagecenter) do
		desc "The id of the Storage Center on which to create the server."
		validate do |value|
		value = value.to_s
			unless value =~ /^[0-9]*$/
				raise ArgumentError, "'%s' is not a valid Storage Center ID." % value
			end
		end
	end
end
		