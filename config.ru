vendor_path = File.expand_path(File.join(File.dirname(__FILE__), "vendor", "sinatra", "lib"))
local_path = File.expand_path(File.dirname(__FILE__))
$:.unshift(local_path) unless $:.include?(local_path)
$:.unshift(vendor_path) unless $:.include?(vendor_path)

require 'rubygems'
require 'sinatra'
 
Sinatra::Application.default_options.merge!(
  :run => false,
  :env => :production
)

require 'mattpayne'
run Sinatra.application
