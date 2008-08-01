class Hash
	def to_html_options
		arr = inject([]) do |a, (k,v)|
			a << "#{k}=\"#{v}\""
			a
		end
		arr.join(" ")
	end
end
