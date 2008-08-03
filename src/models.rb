module MattPayne

	module Models
	
		class Base
		
			include MattPayne::Database
			
			attr_reader :id, :created_at
			
			def initialize(data={})
				set_not_deleted
				set_clean
				set_attributes(data)
			end
			
			def save
				self.class.save(self)
			end
			
			def delete
				self.class.delete(self)
			end
			
			def update_attributes(hash)
				set_attributes(hash, false)
			end
			
			def self.delete(obj)
				return if obj.deleted?
				raise RuntimeError.new("You cannot delete an object that has not been saved.") if obj.new?
				delete_by_id(obj.id)
				obj.send(:set_deleted)
				obj.send(:set_clean)
				obj.instance_variable_set("@id", nil)
				obj.freeze
			end
			
			def self.delete_by_id(id)
				with_database do |db|
					db[table].filter(:id => id).delete
				end
			end
			
			def self.delete_all
				with_database do |db|
					db[table].delete		
				end
			end
			
			def self.save(obj)
				return if obj.nil? || obj.deleted?
				with_database do |db|
					time = Time.now
					if obj.new?
						id = db[table].insert(obj.to_hash.merge(:created_at => time))
						obj.instance_variable_set("@id", id)
						obj.instance_variable_set("@created_at", time)
					elsif !obj.new? && obj.dirty?
						hash = obj.to_hash
						hash.merge!(:updated_at => time) if obj.respond_to?(:updated_at)
						db[table].filter(:id => obj.id).update(hash)
						obj.instance_variable_set("@updated_at", time)
					end
					obj.send(:set_clean)
				end
				obj
			end
			
			def self.all(limit=nil)
				all = []
				with_database do |db|
					data = db[table].limit(limit).order(:created_at.desc) unless (limit.nil? || limit < 1)
					data = db[table].order(:created_at.desc) if (limit.nil? || limit < 1)
					all = data.inject([]) do |arr, row|
						arr << new(row)
						arr
					end
				end
				all
			end
			
			def self.find(id)
				obj = nil
				with_database do |db|
					data = db[table][:id => id]
					obj = new(data) unless data.nil? || data.empty?
				end
				obj
			end
			
			def to_hash
				raise RuntimeError.new("Abstract method!!")
			end
			
			def new?
				self.id.nil?
			end
			
			def deleted?
				@deleted
			end
			
			def dirty?
				@dirty
			end
			
			def valid?
				errors = validate
				errors.nil? || errors.empty?
			end
			
			def validation_errors
				validate
			end
	
			protected
			
			def validate
				required_fields.inject([]){|arr, att| arr << "#{att} is required." if self.send(att).nil? }
			end
			
			def required_fields
				raise RuntimeError.new("Abstract method!!")
			end
			
			def self.table
				raise RuntimeError.new("Abstract method!!")
			end
			
			private
			
			def set_attributes(hash, new=true)
				return if hash.nil? || hash.empty?
				hash.each do |key, value|
					var = "@#{key}"
					unless new
						if self.respond_to?(key.to_sym)
							current_value = self.send(key.to_sym)
							if value != current_value
								set_dirty
							end
						end
					end
					self.instance_variable_set(var, value) unless (value.nil? || !self.respond_to?(key.to_sym))
				end
			end
			
			def set_clean
				@dirty = false
			end
			
			def set_dirty
				@dirty = true			
			end
			
			def set_deleted
				@deleted = true
			end
			
			def set_not_deleted
				@deleted = false
			end
			
			def self.attr_accessor(*symbols)
				return if symbols.nil? || symbols.empty?
				attr_reader *symbols
				symbols.flatten.each {|s|
					self.class_eval(
						%{
							def #{s}=(value)
								unless value == @#{s}
									@#{s} = value
									set_dirty unless new?
								end
							end
						}
					)
				}
			end
			
		end
		
		#---------------------------------------------------------------------------
		
		class Post < Base
		
			attr_accessor :title, :body, :tags
			attr_reader :updated_at
			
			def comments
				@comments ||= Comment.find_for_post(self.id)
			end
			
			def self.find_by_tag(tag)
				matches = []
				with_database do |db|
					data = db[table].filter("tags LIKE '%#{tag}%'").order(:created_at.desc)
					matches = data.inject([]) {|arr, row| arr << new(row); arr} 
				end
				matches
			end
			
			def self.all_tags
				all.map {|post| post.tags.nil? ? nil : post.tags.split(" ") }.flatten.compact.uniq
			end
			
			def to_hash
				{:title => self.title, :body => self.body, :tags => self.tags}
			end
			
			def truncated_body(limit=50)
				if self.body && self.body.length > limit
					@truncated = true
					self.body.slice(0..limit)
				else
					self.body
				end
			end
			
			def truncated_body?
				@truncated || false
			end
			
			protected	
		
			def self.table
				:posts
			end
			
			def required_fields
				[:title, :body]
			end
			
		end
		
		#---------------------------------------------------------------------------
		
		class Comment < Base
			
			attr_reader :post_id, :comment, :username
			
			def self.find_for_post(post_id)
				results = []
				with_database do |db|
					results = db[table].filter(:post_id => post_id).order(:created_at.desc).inject([]) do |arr, row|
						arr << new(row)
						arr
					end
				end
				results
			end
			
			def post
				@post ||= Post.find(self.post_id)
			end
			
			def to_hash
				{:post_id => self.post_id, :comment => self.comment, :username => self.username}
			end
			
			protected	
		
			def self.table
				:comments
			end
			
			def required_fields
				[:comment]
			end
						
		end
	
	end

end
