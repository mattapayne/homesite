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
          db = Sequel.connect(Config.connection_string)
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
          db.execute("DROP TABLE comments;")
          db.execute("DROP TABLE posts;")
          db.execute(%{create table posts (
					id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, title VARCHAR(255) NOT NULL, body TEXT NOT NULL, created_at DATETIME NOT NULL, updated_at DATETIME);})
          db.execute(%{create table comments (
					id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, comment TEXT NOT NULL, username VARCHAR(100), post_id INT NOT NULL, created_at DATETIME NOT NULL);})
          db.execute("ALTER TABLE comments ADD FOREIGN KEY(post_id) REFERENCES posts(id);")
        end
      end
		
    end
	
  end

end
