helpers do

	include MattPayne::HtmlTags
	include Rack::Utils
	include MattPayne::Models
	include MattPayne::Captcha
	include MattPayne::Security
	include MattPayne::Tumblr
  
  alias_method :h, :escape_html

	def render_rte
		%{
			<script language="javascript" type="text/javascript" src="/assets/jscripts/tiny_mce/tiny_mce.js"></script>
			<script language="javascript" type="text/javascript">
				tinyMCE.init({
					theme : "advanced",
					mode : "exact",
					elements : "_textarea",
					theme_advanced_toolbar_location : "top",
					theme_advanced_toolbar_align : "left"
				});
			</script>
		}
	end
	
	def render_github_repos(repos)
		partial(:github_repositories, :locals => {:repos => repos})
	end
	
	def render_tumblr_posts(posts)
		partial(:tumblr_posts, :locals => {:posts => posts})
	end
	
	def render_tags(tags)
		partial(:tags, :locals => {:tags => tags})
	end
	
	def render_full_post(post)
		partial(:post, :locals => {:post => post, :show_complete => true})
	end
	
	def render_partial_post(post)
		partial(:post, :locals => {:post => post, :show_complete => false})
	end
	
	def partial(name, options={})
  	erb(name, options.merge(:layout => false))
  end

	def link_to_randomize_tag_size(tag)
		font = [8, 12, 14, 18, 20, 24].sort_by {rand}.first
		link_to(tag, "/posts/#{tag}", :style => "font-size:#{font}px;")
	end
	
	def render_captcha(html_options={})
		remote_image_tag(captcha_url(), html_options)
	end
	
	def render_post_body(post, limit=100)
		text = post.truncated_body(limit)
		link = nil
		if post.truncated_body?
			link = link_to("Read more ...", "/post/#{post.id}")
			puts "LINK: #{link}"
		end
		text += " #{link}" unless link.nil?
		puts "TEXT: #{text}"
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
