# Provider for login custom type

require 'puppet/files/dsm_api_login'

Puppet::Type.type(:dellstorageprovisioning_login).provide(:login_provider) do
	@doc = 'manage Login and cookie creation.'
	
	def create
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