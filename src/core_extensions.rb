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

	#------------ Basically flat out copied from Stringex (http://github.com/rsl/stringex/tree/master) ------#
	def slugify
		remove_formatting.downcase.replace_whitespace("-").collapse("-")
	end
	
	def convert_accented_entities
  	gsub(/&([A-Za-z])(grave|acute|circ|tilde|uml|ring|cedil|slash);/, '\1')
  end
  
  def convert_misc_entities
  	dummy = dup 
  	{
        "#822[01]" => "\"",
        "#821[67]" => "'",
        "#8230" => "...",
        "#8211" => "-",
        "#8212" => "--",
        "#215" => "x",
        "gt" => ">",
        "lt" => "<",
        "(#8482|trade)" => "(tm)",
        "(#174|reg)" => "(r)",
        "(#169|copy)" => "(c)",
        "(#38|amp)" => "and",
        "nbsp" => " ",
        "(#162|cent)" => " cent",
        "(#163|pound)" => " pound",
        "(#188|frac14)" => "one fourth",
        "(#189|frac12)" => "half",
        "(#190|frac34)" => "three fourths",
        "(#176|deg)" => " degrees"
   	}.each do |textiled, normal|
    	dummy.gsub!(/&#{textiled};/, normal)
    end
  	dummy.gsub(/&[^;]+;/, "")
	end
	
	def convert_misc_characters
      dummy = dup.gsub(/\.{3,}/, " dot dot dot ") # Catch ellipses before single dot rule!
      {
				/\s*&\s*/ => "and",
				/\s*#/ => "number",
				/\s*@\s*/ => "at",
				/(\S|^)\.(\S)/ => '\1 dot \2',
				/(\s|^)\$(\d*)(\s|$)/ => '\2 dollars',
				/\s*\*\s*/ => "star",
				/\s*%\s*/ => "percent",
				/\s*(\\|\/)\s*/ => "slash",
      }.each do |found, replaced|
        replaced = " #{replaced} " unless replaced =~ /\\1/
        dummy.gsub!(found, replaced)
      end
  	dummy = dummy.gsub(/(^|\w)'(\w|$)/, '\1\2').gsub(/[\.,:;()\[\]\/\?!\^'"_]/, " ")
 	end

	def replace_whitespace(replace = " ")
  	gsub(/\s+/, replace)
	end
 	
	def remove_formatting
  	strip_html_tags.convert_accented_entities.convert_misc_entities.convert_misc_characters.collapse
	end
    
	def collapse(character = " ")
  	sub(/^#{character}*/, "").sub(/#{character}*$/, "").squeeze(character)
  end
    
	def strip_html_tags(leave_whitespace = false)
  	name = /[\w:_-]+/
   	value = /([A-Za-z0-9]+|('[^']*?'|"[^"]*?"))/
  	attr = /(#{name}(\s*=\s*#{value})?)/
 		rx = /<[!\/?\[]?(#{name}|--)(\s+(#{attr}(\s+#{attr})*))?\s*([!\/?\]]+|--)?>/
  	(leave_whitespace) ? gsub(rx, "").strip : gsub(rx, "").gsub(/\s+/, " ").strip
 	end
 	
 	#------------------------------------------------------------------------------#
	
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
