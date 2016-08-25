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
require 'base64'
require 'net/https'
require 'json'

class DSMAPIRequest

	attr_accessor :response, :code, :body, :message, :api_version, :content_type
	
	# Formatting methods
	
	# Converts the payload to json
	def self.format_payload(req, payload)
		req.body = payload.to_json
		req
	end
	
	# Creates the headers used in all REST calls
	def self.format_headers(req)
		req["x-dell-api-version"] = @api_version
		req["Content-Type"] = @content_type
		req["Cookie"] = $cookie
		req
	end
	
	# Set the scheme and verification
	def self.define_https(url)
		http = Net::HTTP.new(url.host, url.port)
		http.use_ssl = (url.scheme = "https")
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		http
	end
	
	# Create the nested hash for a filter
	def self.define_filter(filters)
		filter_array = []
		filters.each do |filter|
			filter_hash = {
				"AttributeName" => filter[0],
				"AttributeValue" => filter[1],
				"FilterType" => filter[2]
			}
			filter_array.push(filter_hash)
		end
		
		payload_filter = {
			"Filter" => {
				"FilterType" => "AND",
				"Filters" => filter_array
			}
		}
		payload_filter
	end
	
	# Ensures that the call succeeded
	def self.check_resp(resp, url)
		unless resp.code =~ /^2/
			raise Puppet::Error, "Call to #{url} failed: #{resp.code} #{resp.message}: #{resp.body}"
		end
	end

	# REST methods
	
	def self.post(url, payload)
		url = URI.parse(url)
		
		http = define_https(url)
		
		req = Net::HTTP::Post.new(url.request_uri)
		req = format_headers(req)
		req = format_payload(req, payload)
		
		response = http.request(req)
		response
	end
	
	def self.get(url)
		url = URI.parse(url)
		http = define_https(url)
		
		req = Net::HTTP::Get.new(url.request_uri)
		req = format_headers(req)
		
		response = http.request(req)
		response
	end
	
	def self.delete(url)
		url = URI.parse(url)
		http = define_https(url)
		
		req = Net::HTTP::Delete.new(url.request_uri)
		req = format_headers(req)
		
		response = http.request(req)
		response
	end
	
	# Login methods
	
	def self.make_connection(url, user, pass)
		Puppet.debug("Inside make_connection method of DSMAPIRequest.")
		url = URI.parse(url)
		
		http = define_https(url)
		
		# The initial login call uses different headers
		req = Net::HTTP::Post.new(url.request_uri)
		req.basic_auth(user, pass)
		req["x-dell-api-version"] = @api_version
		req["Content-Type"] = @content_type
		
		response = http.request(req)
		
		response
	end
	
	def self.login(ip, user, pass, folder_name, port_num)
		Puppet.debug("Inside login method of DSMAPIRequest.")
		# Setting configuration details
		$base_url = "https://" + ip + ":#{port_num}/api/rest"
		@api_version = "3.0"
		@content_type = "application/json"
		url = "#{$base_url}/ApiConnection/Login"
		# Logging in
		resp = DSMAPIRequest.make_connection(url, user, pass)
		# Retrieving cookie
		cookie =
			if resp.code =~ /^2/
				resp["Set-Cookie"]
			else
				raise Puppet::Error, "Login as user '#{user}' failed: #{resp.code} #{resp.message}: #{resp.body}"
				nil
			end
		
		# This is the only method that writes the global variables
		$cookie = cookie
		$puppet_folder = folder_name
		
		Puppet.info "Login Successful."
	end
end