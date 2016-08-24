require 'base64'
require 'net/https'
require 'json'

class DSMAPIRequest

	attr_accessor :response, :code, :body, :message, :api_version, :content_type
	
	# Formatting methods
	
	def self.format_payload(req, payload)
		req.body = payload.to_json
		req
	end
	
	def self.format_headers(req)
		req["x-dell-api-version"] = @api_version
		req["Content-Type"] = @content_type
		req["Cookie"] = $cookie
		req
	end
	
	def self.define_https(url)
		http = Net::HTTP.new(url.host, url.port)
		http.use_ssl = (url.scheme = "https")
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		http
	end
	
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
		
		req = Net::HTTP::Post.new(url.request_uri)
		req.basic_auth(user, pass)
		req["x-dell-api-version"] = @api_version
		req["Content-Type"] = @content_type
		
		response = http.request(req)
		
		response
	end
		
	
	def self.login(ip, user, pass, folder_name, port_num)
		Puppet.debug("Inside login method of DSMAPIRequest.")
		$base_url = "https://" + ip + ":#{port_num}/api/rest"
		@api_version = "3.0"
		@content_type = "application/json"
		url = "#{$base_url}/ApiConnection/Login"
		resp = DSMAPIRequest.make_connection(url, user, pass)
		cookie =
			if resp.code =~ /^2/
				resp["Set-Cookie"]
			else
				raise Puppet::Error, "Login as user '#{user}' failed: #{resp.code} #{resp.message}: #{resp.body}"
				nil
			end
		
		# This is the only method that writes these variables
		$cookie = cookie
		
		$puppet_folder = folder_name
		
		Puppet.info "Login Successful."
	end
end