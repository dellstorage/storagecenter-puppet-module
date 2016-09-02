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
# Server folder custom type
# This file presents a Server Folder and its properties to Puppet as an object that it can manage.
#
Puppet::Type.newtype(:dellstorageprovisioning_server_folder) do
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