require 'yaml'

module MattPayne

  class Config
		
    @@config = nil
    @@cache = {}
		
    def self.config
      @@config.blank? ? load_config : @@config
    end
    
    def spam_limit
      value_for_key(:spam_limit)
    end
    
    def self.gmail_username
      value_for_key(:gmail_username)
    end
    
    def self.gmail_password
      value_for_key(:gmail_password)
    end
    
    def self.min_acceptable_spaminess
      value_for_key(:min_acceptable_spamminess)
    end
    
    def self.google_maps_api_key
      value_for_key(:gmaps_key)
    end
		
    def self.admin_username
      value_for_key(:admin_username)
    end
		
    def self.admin_password
      value_for_key(:admin_password)
    end
		
    def self.tumblr_url
      value_for_key(:tumblr_url)
    end
		
    def self.github_url
      value_for_key(:github_url)
    end
    
    def self.connection_string
      value_for_key(:connection_string)
    end
    
    def self.defensio_api_key
      value_for_key(:defensio_key)
    end
    
    def self.defensio_owner_url
      value_for_key(:owner_url)
    end
    
    private
		
    def self.value_for_key(key)
      value = retrieve_from_cache(key)
      return value unless value.blank?
      found = self.config[key.to_sym]
      unless found.blank?
        store_in_cache(key, found)
      end
      return retrieve_from_cache(key)
    end
		
    def self.load_config
      YAML.load(File.open("config.yml", "r"))
    end
		
    def self.retrieve_from_cache(key)
      @@cache[key.to_sym]
    end
		
    def self.store_in_cache(key, value)
      @@cache[key.to_sym] = value
    end
		
  end
	
end
