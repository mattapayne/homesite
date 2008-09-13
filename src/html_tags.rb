module MattPayne
	
  module HtmlTags
		
    def link_to(link_text, url, html_options={})
      "<a href=\"#{url}\" #{html_options.to_html_options}>#{link_text}</a>"
    end
	
    def image_tag(image_name, html_options={})
      default_opts = {:border => "0px", :alt => file_name_without_ext(image_name)}
      default_opts.merge!(html_options)
      "<img src=\"/assets/#{image_name}\" #{default_opts.to_html_options} />"
    end
	
    def remote_image_tag(url, html_options={})
      default_opts = {:border => "0px"}
      default_opts.merge!(html_options)
      "<img src=\"#{url}\" #{default_opts.to_html_options} />"
    end
	
    def image_link_to(image_name, url, link_options={}, image_options={})
      link_to(image_tag(image_name, image_options), url, link_options)
    end
	
    def email_link_to(text, email, html_options={})
      link_to(text, "mailto:#{email}", html_options)
    end
	
    def image_email_link_to(image_name, email, image_html_options={}, email_link_options={})
      email_link_to(image_tag(image_name, image_html_options), email, email_link_options)
    end
	
    def start_form(url, method="post", html_options={})
      "<form action=\"#{url}\" method=\"#{method}\" #{html_options.to_html_options}>"
    end
	
    def end_form
      "</form>"
    end
	
    def submit_button(text="Submit", html_options={})
      input_tag({:type => "submit", :value => text}, html_options)
    end
    
    def button_tag(text, html_options={})
      input_tag({:type => "button", :value => text}, html_options)
    end
	
    def text_area_tag(name, html_options={})
      default_opts = {:rows => 5, :cols => 40}
      default_opts.merge!(html_options)
      value = default_opts.delete(:value)
      "<textarea id=\"_textarea\" name=\"#{name}\" #{default_opts.to_html_options}>#{value}</textarea>"
    end
	
    def password_field_tag(name, html_options={})
      input_tag({:type => "password", :id => "#_{name}", :name => name}, html_options)
    end
	
    def text_field_tag(name, html_options={})
      input_tag({:type => "text", :id => "_#{name}", :name => name}, html_options)
    end
	
    def hidden_field_tag(name, html_options={})
      id = name
      unless name =~ /^_.*$/
        id = "_#{name}" 
      end
      input_tag({:type => "hidden", :name => name, :id => id}, html_options)
    end
		
    private
		
    def input_tag(options, html_options={})
      options.merge!(html_options) 
      "<input #{options.to_html_options} />"
    end
		
  end
	
end
