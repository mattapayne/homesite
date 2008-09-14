module MattPayne

  class Config
		
    @@config = nil
    @@cache = {}
		
    def self.config
      @@config ||= load_config
    end
	
    def self.captcha_key
      value_for_key(:captcha_key)
    end
    
    def self.google_maps_api_key
      value_for_key(:gmaps_key)
    end
		
    def self.captcha_username
      value_for_key(:captcha_username)
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
      connection_string = retrieve_from_cache(:connection_string)
      return connection_string unless connection_string.blank?
      f = nil
      begin
        f = File.open("config.txt", "r")
        connection_string = f.read()
        store_in_cache(:connection_string, connection_string.strip().chomp())
      ensure
        unless f.nil?
          f.close()
        end
      end
      return retrieve_from_cache(:connection_string)
    end
    
    private
		
    def self.value_for_key(key)
      value = retrieve_from_cache(key)
      return value unless value.blank?
      found = self.config.select {|setting| setting.name.to_s == key.to_s}
      unless found.blank?
        store_in_cache(key, found.first.value)
      end
      return retrieve_from_cache(key)
    end
		
    def self.load_config
      current_env = Sinatra.application.options.env.to_s.downcase
      Setting.all.select { |s| s.environment.to_s.downcase == current_env }
    end
		
    def self.retrieve_from_cache(key)
      @@cache[key.to_s]
    end
		
    def self.store_in_cache(key, value)
      @@cache[key.to_s] = value
    end
		
  end
	
end
