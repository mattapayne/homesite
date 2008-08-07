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
		
		private
		
		def self.value_for_key(key)
			return @@cache[key.to_s] if @@cache.key?(key.to_s)
			found = self.config.select {|setting| setting.name.to_s == key.to_s}
			unless found.blank?
				@@cache[key.to_s] = found.first.value
			end
			return @@cache[key.to_s]
		end
		
		def self.load_config
			@@settings ||= Setting.all.select {|s| 
					s.environment.to_s.downcase == Sinatra.application.options.env.to_s.downcase}
		end
		
	end
	
end
