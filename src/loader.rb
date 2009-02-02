local_path = File.expand_path(File.dirname(__FILE__))

$:.unshift(local_path) unless $:.include?(local_path)

require 'rubygems'
require 'app_logger'
require 'rdefensio'
require 'sinatra'
require 'core_extensions'
require 'config'
require 'tumblr'
require 'github'
require 'blog_to_rss'
require 'database'
require 'models'
require 'html_tags'
require 'security'
require 'helpers'
require 'controller_helpers'
require 'smtp_tls'
require 'gmailer'
