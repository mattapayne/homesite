module MattPayne

	module Models
	
		class Tag
			
			attr_reader :count, :tag
			
			def initialize(tag, count)
				@count, @tag = count, tag
			end
			
		end
		
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
				return if obj.deleted? || obj.new?
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
				return if obj.blank? || obj.deleted?
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
			
			def self.paged(limit=5, page=1)
				page ||= 1
				paged = PagingArray.new(page.to_i, 0)
				with_database do |db|
					data = db[table].paginate(page.to_i, limit.to_i).order(:created_at.desc)
					paged = data.inject(PagingArray.new(page, data.page_count)) { |arr, row| arr << new(row); arr}
				end
				paged
			end
			
			def self.all(limit=nil)
				all = []
				with_database do |db|
					data = db[table].limit(limit).order(:created_at.desc) unless (limit.blank? || limit < 1)
					data = db[table].order(:created_at.desc) if (limit.blank? || limit < 1)
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
					obj = new(data) unless data.blank?
				end
				obj
			end
			
			def to_hash
				raise RuntimeError.new("Abstract method!!")
			end
			
			def new?
				self.id.blank?
			end
			
			def deleted?
				@deleted
			end
			
			def dirty?
				@dirty
			end
			
			def valid?
				validate.blank?
			end
			
			def validation_errors
				validate
			end
	
			protected
			
			def validate
				required_fields.inject([]) do |arr, att| 
					arr << "#{att.to_s.capitalize} is required." if self.send(att).blank?
					arr
				end
			end
			
			def required_fields
				raise RuntimeError.new("Abstract method!!")
			end
			
			def self.table
				raise RuntimeError.new("Abstract method!!")
			end
			
			private
			
			def set_attributes(hash, new=true)
				return if hash.blank?
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
					self.instance_variable_set(var, value) if self.respond_to?(key.to_sym)
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
				return if symbols.blank?
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
			
			extend MattPayne::BlogToRss
		
			attr_accessor :title, :body, :tags, :slug
			attr_reader :updated_at
			
			def comments
				@comments ||= Comment.find_for_post(self.id)
			end
			
			def self.find_by_slug(slug)
				obj = nil
				with_database do |db|
					data = db[table][:slug => slug]
					obj = new(data) unless data.blank?
				end
				obj
			end
			
			def self.find_by_tag(tag, limit=5, page="1")
				page ||= 1
				paged = PagingArray.new(page.to_i, 0)
				with_database do |db|
					data = db[table].filter("tags LIKE '%#{tag}%'").paginate(page.to_i, limit.to_i).order(:created_at.desc)
					paged = data.inject(PagingArray.new(page, data.page_count)) { |arr, row| arr << new(row); arr}
				end
				paged
			end
			
			def self.all_tags
				hash = all.inject({}) do |h, post|
					unless post.tags.blank?
						tags = post.tags.split
						tags.each {|t| h.key?(t) ? h[t] += 1 : h[t] = 1}
					end
					h
				end
				hash.inject([]){|arr, (k,v)| arr << Tag.new(k, v); arr}.shuffle
			end
			
			def to_hash
				{:title => self.title, :body => self.body, :tags => self.tags, :slug => self.title.slugify}
			end
			
			def contains_code?
				(self.body =~ /^.*<pre name="code".*$/) != nil
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
		
		class Setting
			
			include MattPayne::Database
			
			attr_reader :name, :value, :environment
			
			def initialize(hash={})
				return if hash.blank?
				hash.each do |key, value|
					var = "@#{key}"
					if respond_to?(key.to_sym)
						self.instance_variable_set(var, value)
					end
				end
			end
			
			def self.all
				@@all ||= fetch_settings
			end
			
			private
			
			def self.fetch_settings
				all = []
				with_database do |db|
					all = db[table].inject([]) {|arr, row| arr << new(row); arr}
				end
				all
			end
			
			def self.table
				:app_settings
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
				[:comment, :username]
			end
						
		end
	
	end

end
