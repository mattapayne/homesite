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
          add_foreign_keys(db)
        end
      end
      
      def add_foreign_keys(db)
        db.execute("ALTER TABLE comments ADD FOREIGN KEY(post_id) REFERENCES posts(id);")
      end
      
      def create_comments(db)
      	db.execute("DROP TABLE IF EXISTS comments;")
      	db.execute(%{create table comments (id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
          comment TEXT NOT NULL, username VARCHAR(100), post_id INT NOT NULL, 
          created_at DATETIME NOT NULL, website VARCHAR(255), email VARCHAR(100),
          signature VARCHAR(100), spam BOOLEAN NOT NULL DEFAULT false,
          spaminess VARCHAR(20) NOT NULL, api_version VARCHAR(10) NOT NULL,
          reviewed BOOLEAN NOT NULL DEFAULT false);})
      end
      
      def create_posts(db)
      	db.execute("DROP TABLE IF EXISTS posts;")
      	db.execute(%{create table posts (id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
          title VARCHAR(255) NOT NULL, slug VARCHAR(255) NOT NULL, body TEXT NOT NULL, 
          tags TEXT, created_at DATETIME NOT NULL, updated_at DATETIME, 
          announced BOOLEAN NOT NULL DEFAULT FALSE, FULLTEXT (title,body,tags));})
      end
      
    end
	
  end

end
