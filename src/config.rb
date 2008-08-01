require 'yaml'

module MattPayne

	class Config
		
		@@config = nil
		
		def self.config
			@@config ||= load_config
		end
		
		def self.config_for_env(env)
			self.config[env.to_sym]
		end
		
		def self.connection_string(env="development")
			config_for_env(env)[:connection_string]
		end
		
		def self.captcha_key(env="development")
			config_for_env(env)[:captcha_key]
		end
		
		def self.captcha_username(env="development")
			config_for_env(env)[:captcha_username]
		end
		
		private
		
		def self.load_config
			YAML.load(File.open(File.expand_path(File.join(File.dirname(__FILE__), "..", 
      	"config", "db.yml")), "r"))			
		end
		
	end
	
end
