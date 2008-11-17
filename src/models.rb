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
			
      def self.paged(limit=5, page="1")
        paged = PagingArray.new(page.to_i, 0, 0)
        with_database do |db|
          data = db[table].paginate(page.to_i, limit.to_i).order(:created_at.desc)
          paged = data.inject(PagingArray.new(
              page, data.page_count, data.pagination_record_count)) { |arr, row| arr << new(row); arr}
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
        arr = validate_custom || []
        required_fields.inject(arr) do |arr, att| 
          arr << "#{att.to_s.capitalize} is required." if self.send(att).blank?
          arr
        end
      end
      
      def validate_custom
        #hook
        nil
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
		
      attr_accessor :title, :body, :tags, :slug, :announced
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
        paged = PagingArray.new(page.to_i, 0, 0)
        with_database do |db|
          data = db[table].filter("tags LIKE '%#{tag}%'").paginate(page.to_i, limit.to_i).order(:created_at.desc)
          paged = data.inject(PagingArray.new(
              page.to_i, data.page_count, data.pagination_record_count)) { |arr, row| arr << new(row); arr}
        end
        paged
      end
      
      def self.search(query, limit=5, page="1")
        paged = PagingArray.new(page.to_i, 0, 0)
        with_database do |db|
          data = db[table].full_text_search([:title, :body, :tags], query).paginate(page.to_i, limit.to_i).order(:created_at.desc)
          paged = data.inject(PagingArray.new(
              page.to_i, data.page_count, data.pagination_record_count )) { |arr, row| arr << new(row); arr}
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
        {
          :title => self.title, :body => self.body, :tags => self.tags, 
          :slug => self.title.slugify, :announced => self.announced
        }
      end
			
      def contains_code?
        (self.body =~ /^.*<pre name="code".*$/) != nil
      end
      
      def too_old_for_comments?
        return (self.created_at + (5*24*60*60)) <= Time.now
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
			
      attr_reader :post_id, :comment, :username, :website, :email
      attr_accessor :signature, :spam, :spaminess, :api_version, :reviewed
      WEBSITE_REGEXP = /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix
      EMAIL_NAME_REGEX  = '[\w\.%\+\-]+'.freeze
      DOMAIN_HEAD_REGEX = '(?:[A-Z0-9\-]+\.)+'.freeze
      DOMAIN_TLD_REGEX  = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'.freeze
      EMAIL_REGEX   = /\A#{EMAIL_NAME_REGEX}@#{DOMAIN_HEAD_REGEX}#{DOMAIN_TLD_REGEX}\z/i
			
      def self.find_for_post(post_id)
        results = []
        with_database do |db|
          results = db[table].filter(:post_id => post_id, :spam => false, :reviewed => true).
            order(:created_at.desc).inject([]) do |arr, row|
            arr << new(row)
            arr
          end
        end
        results
      end
      
      def self.find_by_signature(signature)
        obj = nil
        with_database do |db|
          data = db[table][:signature => signature]
          obj = new(data) unless data.blank?
        end
        obj
      end
      
      def self.all_by_spaminess
        results = []
        with_database do |db|
          results = db[table].order(:spaminess.desc).inject([]) do |arr, row|
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
        {
          :post_id => self.post_id, :comment => self.comment, 
          :username => self.username, :website => convert_url(self.website),
          :email => self.email, :signature => self.signature, :spam => self.spam,
          :spaminess => self.spaminess, :api_version => self.api_version,
          :reviewed => self.reviewed
        }
      end
      
      def has_website?
        !self.website.blank? && website_format_ok?
      end
      
      def has_email?
        !self.email.blank? && email_ok?
      end
      
      def spam?
        self.spam
      end
      
      def reviewed?
        self.reviewed
      end
      
      def possibly_spam?
        (!self.reviewed? && self.spam?) || 
          (!self.reviewed? && self.spaminess.to_f > MattPayne::Config.min_acceptable_spaminess.to_f)
      end
      
      def definitely_spam?
        !self.reviewed? && self.spam? && self.spaminess.to_f >= MattPayne::Config.spam_limit
      end
			
      protected
		
      def self.table
        :comments
      end
			
      def required_fields
        [:comment, :username]
      end
		
      def validate_custom
        custom_errors = []
        if !self.website.blank? && !website_format_ok?
          custom_errors << "The website you've supplied does not appear to be a valid url."
        end
        if !self.email.blank? && !email_ok?
          custom_errors << "The email address you've supplied does not appear to be a valid email address."
        end
        custom_errors.empty? ? nil : custom_errors
      end
      
      private
      
      def website_format_ok?
        convert_url(self.website) =~ WEBSITE_REGEXP
      end
      
      def email_ok?
        self.email =~ EMAIL_REGEX
      end
      
      def convert_url(url)
        return if self.website.blank?
        unless url =~ /^(http|https):\/\/.+/
          url = "http://#{url}"
        end
        return url
      end
      
    end
	
  end

end
