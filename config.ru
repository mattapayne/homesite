vendor_path = File.expand_path(File.join(File.dirname(__FILE__), "vendor", "sinatra", "lib"))
local_path = File.expand_path(File.dirname(__FILE__))
$:.unshift(local_path) unless $:.include?(local_path)
$:.unshift(vendor_path) unless $:.include?(vendor_path)

require 'rack/file'
class Rack::File
   MIME_TYPES = Hash.new { |hash, key|
   Rack::Mime::MIME_TYPES[".#{key}"] }
end

require 'rubygems'
require File.join(vendor_path, 'sinatra')

Sinatra::Application.default_options.merge!(
  :run => false,
  :env => :production,
  :raise_errors => true,
  :sessions => true,
  :app_file => '/home/matt/homesite/mattpayne.rb',
  :root => "/home/matt/homesite",
  :views => "/home/matt/homesite/views"
)

log = File.new("sinatra.log", "a")
STDOUT.reopen(log)
STDERR.reopen(log)

require '/home/matt/homesite/mattpayne'
run Sinatra.application
