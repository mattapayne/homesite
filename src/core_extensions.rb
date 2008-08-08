module CollectionExtensions
	
	def self.included(klazz)
		klazz.send(:include, InstanceMethods)
	end
	
	module InstanceMethods
		
		def not_empty?
			!blank?
		end
		
	end
	
end

class Hash
	include CollectionExtensions
	
	def to_html_options
		arr = inject([]) do |a, (k,v)|
			a << "#{k}=\"#{v}\""
			a
		end
		arr.join(" ")
	end
	
end

class Array
	include CollectionExtensions

	def shuffle
    array = dup
    size.downto 2 do |j|
      r = rand j
      array[j-1], array[r] = array[r], array[j-1]
    end
    array
  end

end

class PagingArray < Array
	
	attr_reader :current_page
	attr_reader :page_count
	
	def initialize(current_page, page_count)
		@current_page, @page_count = current_page, page_count
	end
	
end

class String
	def capitalize
		return self if self == ""
		return "#{self.slice(0...1).upcase}#{self.slice(1..self.length)}"
	end
end

class Object
	def blank?
		respond_to?(:empty?) ? empty? : !self
	end
end
