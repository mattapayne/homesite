class Hash
	def to_html_options
		arr = inject([]) do |a, (k,v)|
			a << "#{k}=\"#{v}\""
			a
		end
		arr.join(" ")
	end
	
	def not_empty?
		!empty?
	end
	
end

class Array
	def not_empty?
		!empty?
	end

	def shuffle
    array = dup
    size.downto 2 do |j|
      r = rand j
      array[j-1], array[r] = array[r], array[j-1]
    end
    array
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
