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
		
		def self.connection_string
			config_for_env(APP_ENV)[:connection_string]
		end
		
		def self.captcha_key
			config_for_env(APP_ENV)[:captcha_key]
		end
		
		def self.captcha_username
			config_for_env(APP_ENV)[:captcha_username]
		end
		
		def self.admin_username
			config_for_env(APP_ENV)[:admin_username]
		end
		
		def self.admin_password
			config_for_env(APP_ENV)[:admin_password]
		end
		
		def self.vendored_items
			config_for_env(APP_ENV)[:vendor]
		end
		
		private
		
		def self.load_config
			YAML.load(File.open(File.expand_path(File.join(File.dirname(__FILE__), "..", 
      	"config", "config.yml")), "r"))			
		end
		
	end
	
end
