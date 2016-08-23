# Provider for login custom type

require 'puppet/files/dsm_api_login'

Puppet::Type.type(:storagemanager_login).provide(:login_provider) do
	@doc = 'manage Login and cookie creation.'
	
	def create
		DSMAPILogin.login(@resource[:name], @resource[:username], @resource[:password])
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