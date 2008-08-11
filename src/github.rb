require 'open-uri'
require 'xmlsimple'
require 'ostruct'

module MattPayne

  module GitHub
	
    def self.repositories
      repos = []
      begin
        xml = open(MattPayne::Config.github_url).read
        tmp = xml.blank? ? {} : XmlSimple.xml_in(xml)
        tmp = extract_repositories(tmp)
        repos = tmp.inject([]) do |arr, r|
          h = {:name => r["name"].first, :url => r["url"].first}
          arr << OpenStruct.new(h) 
          arr
        end
      rescue
        #swallow
      end
      repos
    end
		
    private
		
    def self.extract_repositories(hash)
      return hash["repositories"].first["repository"]
    end
		
  end
	
end
