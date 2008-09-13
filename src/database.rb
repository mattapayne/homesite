require 'sequel'

module MattPayne

  module Database
    
    def self.included(klazz)
      klazz.extend(Connection)
    end
      
    module Connection
		
      def with_database
        begin
          return unless block_given?
          db = Sequel.connect(Sinatra.application.options.connection_string)
          yield(db)
        ensure
          db.disconnect if db
        end
      end
		
    end
		
    module Utils
      
      include Connection
			
      def create_schema
        with_database do |db|
          create_posts(db)
          create_comments(db)
          create_app_settings(db)
          db.execute("ALTER TABLE comments ADD FOREIGN KEY(post_id) REFERENCES posts(id);")
        end
      end
      
      def create_comments(db)
      	db.execute("DROP TABLE IF EXISTS comments;")
      	db.execute(%{create table comments (id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
          comment TEXT NOT NULL, username VARCHAR(100), post_id INT NOT NULL, created_at DATETIME NOT NULL);})
      end
      
      def create_posts(db)
      	db.execute("DROP TABLE IF EXISTS posts;")
      	db.execute(%{create table posts (id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
          title VARCHAR(255) NOT NULL, slug VARCHAR(255) NOT NULL, body TEXT NOT NULL, 
          tags TEXT, created_at DATETIME NOT NULL, updated_at DATETIME, FULLTEXT (title,body,tags));})
      end
      
      def add_post_slug(db)
      	db.execute(%{ALTER TABLE posts ADD slug VARCHAR(255);})
      end
      
      def make_posts_full_text(db)
        db.execute("ALTER TABLE posts ADD FULLTEXT (title, body, tags);")
      end
      
      def add_google_maps_api_key(db)
        db.execute(%{INSERT INTO app_settings (name, value, environment) VALUES ('gmaps_key', 
          'ABQIAAAAmKfFxA14dHoBadEFep47iRQwHu3rQCyfTgH93yBlkTR7UAz0_BQABOpQxFTILdJiz_tUXzDmxR5L9Q', 'development');})
        db.execute(%{INSERT INTO app_settings (name, value, environment) VALUES ('gmaps_key', 
          'ABQIAAAAmKfFxA14dHoBadEFep47iRQwHu3rQCyfTgH93yBlkTR7UAz0_BQABOpQxFTILdJiz_tUXzDmxR5L9Q', 'test');})
        db.execute(%{INSERT INTO app_settings (name, value, environment) VALUES ('gmaps_key', 
          'ABQIAAAAmKfFxA14dHoBadEFep47iRQwHu3rQCyfTgH93yBlkTR7UAz0_BQABOpQxFTILdJiz_tUXzDmxR5L9Q', 'production');})
      end
      
      def create_app_settings(db)
      	db.execute("DROP TABLE IF EXISTS app_settings;")
      	db.execute(%{create table app_settings (name VARCHAR(100) NOT NULL, value VARCHAR(255) NOT NULL, 
          environment VARCHAR(30));})
      	
      	db.execute(%{INSERT INTO app_settings (name, value, environment) 
          VALUES ('captcha_key', '6Y7E402rgYu2FdM5m0yVMgnZ2CSSeEwNNMl5sbXl', 'development');})
      	db.execute(%{INSERT INTO app_settings (name, value, environment) 
          VALUES ('captcha_key', '6Y7E402rgYu2FdM5m0yVMgnZ2CSSeEwNNMl5sbXl', 'test');})
      	db.execute(%{INSERT INTO app_settings (name, value, environment) 
          VALUES ('captcha_key', '6Y7E402rgYu2FdM5m0yVMgnZ2CSSeEwNNMl5sbXl', 'production');})
      	
      	db.execute(%{INSERT INTO app_settings (name, value, environment) VALUES ('captcha_username', 'mattpayne', 'development');})
      	db.execute(%{INSERT INTO app_settings (name, value, environment) VALUES ('captcha_username', 'mattpayne', 'test');})
      	db.execute(%{INSERT INTO app_settings (name, value, environment) VALUES ('captcha_username', 'mattpayne', 'production');})
      	
      	db.execute(%{INSERT INTO app_settings (name, value, environment) VALUES ('tumblr_url', 
      		'http://mpayne.tumblr.com/api/read?type=regular&num=5', 'development');})
      	db.execute(%{INSERT INTO app_settings (name, value, environment) VALUES ('tumblr_url', 
      		'http://mpayne.tumblr.com/api/read?type=regular&num=5', 'test');})
      	db.execute(%{INSERT INTO app_settings (name, value, environment) VALUES ('tumblr_url', 
      		'http://mpayne.tumblr.com/api/read?type=regular&num=5', 'production');})	
      		
      	db.execute(%{INSERT INTO app_settings (name, value, environment) VALUES ('github_url',
      		'http://github.com/api/v1/xml/mattapayne', 'development');})
      	db.execute(%{INSERT INTO app_settings (name, value, environment) VALUES ('github_url',
      		'http://github.com/api/v1/xml/mattapayne', 'test');})
      	db.execute(%{INSERT INTO app_settings (name, value, environment) VALUES ('github_url',
      		'http://github.com/api/v1/xml/mattapayne', 'production');})
      		
      	db.execute(%{INSERT INTO app_settings (name, value, environment) VALUES ('admin_username', 'mpayne', 'development');})
      	db.execute(%{INSERT INTO app_settings (name, value, environment) VALUES ('admin_username', 'mpayne', 'test');})
       	db.execute(%{INSERT INTO app_settings (name, value, environment) VALUES ('admin_username', 'mpayne', 'production');})
      	
      	db.execute(%{INSERT INTO app_settings (name, value, environment) VALUES ('admin_password', 'mojothemonkey', 'development');})
      	db.execute(%{INSERT INTO app_settings (name, value, environment) VALUES ('admin_password', 'mojothemonkey', 'test');})
      	db.execute(%{INSERT INTO app_settings (name, value, environment) VALUES ('admin_password', 'mojothemonkey', 'production');})
  
      end
		
    end
	
  end

end
