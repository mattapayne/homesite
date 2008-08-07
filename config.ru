vendor_path = File.expand_path(File.join(File.dirname(__FILE__), "vendor", "sinatra", "lib"))
local_path = File.expand_path(File.dirname(__FILE__))
$:.unshift(local_path) unless $:.include?(local_path)
$:.unshift(vendor_path) unless $:.include?(vendor_path)

require 'rubygems'
require 'sinatra'

Sinatra::Application.default_options.merge!(
  :run => false,
  :env => :production,
  :raise_errors => true,
  :sessions => true,
  :app_file => '/home/matt/homesite/mattpayne.rb',
  :root => "/home/matt/homesite",
  :views => "/home/matt/homesite/views"
)

log = File.new("sinatra.log", "w")
STDOUT.reopen(log)
STDERR.reopen(log)

require '/home/matt/homesite/mattpayne'
run Sinatra.application
