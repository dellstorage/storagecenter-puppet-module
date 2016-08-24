# This class takes an ip address, username, and password.
# It makes a connection to the dsm_login
# It returns a cookie and a base url for future calls to use.

require 'base64'
require 'json'
require 'net/https'

class DSMAPILogin

	attr_accessor :resp
	
	def self.make_url(ip)
		Puppet.debug("Inside make_url method of DSMAPILogin.")
		url = "https://" + ip + ":3033/api/rest/ApiConnection/Login"
		url
	end
	
	def self.make_connection(url, user, pass)
		Puppet.debug("Inside make_connection method of DSMAPILogin.")
		url = URI.parse(url)
		puts url
		
		http = Net::HTTP.new(url.host, url.port)
		http.use_ssl = (url.scheme == "https")
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		http.ssl_version = :TLSv1_2
		
		req = Net::HTTP::Post.new(url.request_uri)
		req.basic_auth(user, pass)
		req["x-dell-api-version"] = $api_version
		req["Content-Type"] = $content_type
		
		resp = http.request(req)
		
		resp
	end
		
	
	def self.login(ip, user, pass, folder_name)
		Puppet.debug("Inside login method of DSMAPILogin.")
		$base_url = "https://" + ip + ":3033/api/rest"
		$api_version = "3.0"
		$content_type = "application/json"
		url = "#{$base_url}/ApiConnection/Login"
		url = DSMAPILogin.make_url(ip)
		resp = DSMAPILogin.make_connection(url, user, pass)
		cookie =
			if resp.code =~ /^2/
				resp["Set-Cookie"]
			else
				raise Puppet::Error, "Login as user '#{user}' failed: #{resp.code} #{resp.message}"
				nil
			end
		
		# This is the only method that writes these variables
		$cookie = cookie
		
		$puppet_folder = folder_name
		
		Puppet.info "Login Successful."
	end
end