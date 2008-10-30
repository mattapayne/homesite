require 'open-uri'
require 'xmlsimple'
require 'ostruct'
require 'timeout'

module MattPayne

  module GitHub
	
    def self.repositories
      repos = []
      begin
        Timeout::timeout(10) do
          xml = open(MattPayne::Config.github_url).read
          tmp = xml.blank? ? {} : XmlSimple.xml_in(xml)
          tmp = extract_repositories(tmp)
          repos = tmp.inject([]) do |arr, r|
            h = {:name => r["name"].first, :url => r["url"].first}
            arr << OpenStruct.new(h) 
            arr
          end
        end
      rescue Timeout::Error => e
        #swallow
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
