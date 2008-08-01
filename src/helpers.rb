helpers do

	def link_to(link_text, url, html_options={})
		"<a href=\"#{url}\" #{html_options.to_html_options}>#{link_text}</a>"
	end
	
	def image_tag(image_name, html_options={})
		default_opts = {:border => "0px", :alt => file_name_without_ext(image_name)}
		default_opts.merge!(html_options)
		"<img src=\"/assets/#{image_name}\" #{default_opts.to_html_options} />"
	end
	
	def image_link_to(image_name, url, link_options={}, image_options={})
		link_to(image_tag(image_name, image_options), url, link_options)
	end
	
	def email_link_to(text, email, html_options={})
		"<a href=\"mailto:#{email}\" #{html_options.to_html_options}>#{text}</a>"
	end
	
	def image_email_link_to(image_name, email, image_html_options={}, email_link_options={})
		email_link_to(image_tag(image_name, image_html_options), email, email_link_options)
	end
	
	def start_form(url, method="post")
		"<form action=\"#{url}\" method=\"#{method}\">"
	end
	
	def end_form
		"</form>"
	end
	
	def submit_button(text="Submit", html_options={})
		"<input type=\"submit\" value=\"#{text}\" #{html_options.to_html_options} />"
	end
	
	def text_area_tag(name, html_options={})
		default_opts = {:rows => 5, :cols => 40}
		default_opts.merge!(html_options)
		%{<textarea id=\"#{name}\" name=\"#{name}\" #{default_opts.to_html_options}></textarea>}
	end
	
	def hidden_field_tag(name, html_options={})
		%{<input type=\"hidden\" name=\"#{name}\" id=\"#{name}\" #{html_options.to_html_options} />}
	end
	
	def render_post_body(post, limit=50)
		text = post.truncated_body(limit)
		link = nil
		if post.truncated_body?
			link = link_to("Read more ...", "/post/#{post.id}")
		end
		text += " #{link}" unless link.nil?
		text
	end
	
	def datetime(date, format="%I:%M%p on %m/%d/%Y")
		date.strftime(format)
	end
	
	private
	
	def file_name_without_ext(file)
		index = file.index(".")
		file.slice(0...index)
	end
	
end
