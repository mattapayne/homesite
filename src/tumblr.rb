require 'open-uri'
require 'xmlsimple'

module MattPayne

	module Tumblr
	
		def tumblr_posts
			results = open(MattPayne::Config.tumblr_url).read
			posts = results.blank? ? {} : XmlSimple.xml_in(results)
			return posts["posts"][0]["post"] unless posts.blank?
			return posts
		end
		
	end
	
end
