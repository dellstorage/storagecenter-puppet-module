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
# HBA custom type
# This file presents an HBA and its properties to Puppet as an object that it can manage.
#
Puppet::Type.newtype(:dellstorageprovisioning_hba) do
	@doc = "Manage Server HBA creation, modification, and deletion."
	
	ensurable
	
	newparam(:allowmanual) do
		desc "Allows the HBA to be added to the Server even if the HBA is not visible on the Storage Center."
		newvalues(:true, :false)
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