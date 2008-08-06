require 'open-uri'
require 'xmlsimple'

module MattPayne

	module Tumblr
	
		def tumblr_posts
			results = nil
			begin
				results = open(MattPayne::Config.tumblr_url).read
			rescue
				#swallow
			end
			posts = results.blank? ? {} : XmlSimple.xml_in(results)
			return posts.blank? ? posts : extract_posts(posts)
		end
		
		private
		
		def extract_posts(hash)
			hash["posts"].blank? ? {} : (hash["posts"].first["post"].blank? ? {} : hash["posts"].first["post"])
		end
		
	end
	
end
