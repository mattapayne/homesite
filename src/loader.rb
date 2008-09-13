local_path = File.expand_path(File.dirname(__FILE__))
vendor_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "vendor", "sinatra", "lib"))

$:.unshift(local_path) unless $:.include?(local_path)
$:.unshift(vendor_path) unless $:.include?(vendor_path)

require 'rubygems'
require 'sinatra'
require 'core_extensions'
require 'config'
require 'tumblr'
require 'github'
require 'blog_to_rss'
require 'database'
require 'models'
require 'captcha'
require 'html_tags'
require 'security'
require 'helpers'
require 'controller_helpers'
