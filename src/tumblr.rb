require 'open-uri'
require 'xmlsimple'
require 'ostruct'
require 'timeout'

module MattPayne

  module Tumblr
	
    def self.posts
      posts = []
      begin
        Timeout::timeout(5) do
          xml = open(MattPayne::Config.tumblr_url).read
          tmp = xml.blank? ? {} : XmlSimple.xml_in(xml)
          tmp = extract_posts(tmp)
          posts = tmp.inject([]) do |arr, p|
            h = {:url => p["url"], :title => p["regular-title"].first, :date => p["date"]}
            arr << OpenStruct.new(h)
            arr
          end 
        end
      rescue Timeout::Error => e
        #swallow
      rescue
        #swallow
      end
      posts
    end
		
    private
		
    def self.extract_posts(hash)
      hash["posts"].blank? ? {} : 
        (hash["posts"].first["post"].blank? ? {} : 
          hash["posts"].first["post"])
    end
		
  end
	
end
