require 'rubygems'
gem "sinatra", "~> 0.9"

local_path = File.expand_path(File.dirname(__FILE__))
$:.unshift(local_path) unless $:.include?(local_path)

require File.join(local_path, "mattpayne")

set :run, false
set :environment, :production
set :sessions, true
set :raise_errors, true
set :root, local_path
set :views, File.join(local_path, "views")
set :app_file, File.join(local_path, "mattpayne.rb")

log = File.new("sinatra.log", "a")
STDOUT.reopen(log)
STDERR.reopen(log)

run Sinatra::Application
