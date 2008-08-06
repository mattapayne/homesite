require 'open-uri'
require 'xmlsimple'

module MattPayne

	module GitHub
	
		def self.repositories
			results = nil
			begin
				results = open(MattPayne::Config.github_url).read
			rescue
				#swallow
			end
			data = results.blank? ? {} : XmlSimple.xml_in(results)
			return data.blank? ? data : extract_repositories(data)
		end
		
		private
		
		def self.extract_repositories(hash)
			return hash["repositories"].first["repository"]
		end
		
	end
	
end
