class Hash
	def to_html_options
		arr = inject([]) do |a, (k,v)|
			a << "#{k}=\"#{v}\""
			a
		end
		arr.join(" ")
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
