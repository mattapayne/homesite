require 'rubygems'

APP_ENV = "development" unless defined?(APP_ENV)

require 'src/core_extensions'
require 'src/config'

local_dir = File.expand_path(File.dirname(__FILE__))

MattPayne::Config.vendored_items.each do |vendor_dir, require_file|
	require File.join(local_dir, vendor_dir.to_s, require_file.to_s)	
end

require 'src/database'
require 'src/models'
require 'src/captcha'
require 'src/html_tags'
require 'src/helpers'
require 'src/security'


