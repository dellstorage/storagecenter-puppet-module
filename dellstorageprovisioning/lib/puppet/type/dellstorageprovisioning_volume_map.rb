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
# Mapping custom type
# This file presents mapping to Puppet as an object that it can manage.
#
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