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
# Provider for login custom type
# The login provider will always return false due to credential timeout
#
require 'puppet/files/dsm_api_login'

Puppet::Type.type(:dellstorageprovisioning_login).provide(:login_provider) do
	@doc = 'manage Login and cookie creation.'
	
	# Logging in
	def create
		Puppet.info "Logging in as #{@resource[:username]}."
		DSMAPIRequest.login(@resource[:name], @resource[:username], @resource[:password], @resource[:main_folder_name], @resource[:port_number])
	end
	
	def destroy
		# Session will timeout automatically
	end
	
	# This method always returns false
	# A new login will be made for each puppet run
	def exists?
		return false
	end
end