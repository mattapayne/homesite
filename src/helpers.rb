helpers do

	include MattPayne::HtmlTags
	include Rack::Utils
	include MattPayne::Captcha
	include MattPayne::Security
  
  alias_method :h, :escape_html
  
  def render_syntax
  	%{
  		<link type="text/css" rel="stylesheet" href="/assets/hilight/SyntaxHighlighter.css"></link>
			<script language="javascript" src="/assets/hilight/shCore.js"></script>
			<script language="javascript" src="/assets/hilight/shBrushRuby.js"></script>
			<script language="javascript" src="/assets/hilight/shBrushCss.js"></script>
			<script language="javascript" src="/assets/hilight/shBrushJava.js"></script>
			<script language="javascript" src="/assets/hilight/shBrushPython.js"></script>
			<script language="javascript" src="/assets/hilight/shBrushSql.js"></script>
			<script language="javascript" src="/assets/hilight/shBrushJScript.js"></script>
			<script language="javascript" src="/assets/hilight/shBrushCSharp.js"></script>
			<script language="javascript" src="/assets/hilight/shBrushXml.js"></script>
			<script language="javascript">
				dp.SyntaxHighlighter.ClipboardSwf = '/assets/hilight/clipboard.swf';
				dp.SyntaxHighlighter.HighlightAll('code');
			</script>
  	}
  end

	def render_rte
		%{
			<script language="javascript" type="text/javascript" src="/assets/jscripts/tiny_mce/tiny_mce.js"></script>
			<script language="javascript" type="text/javascript">
				tinyMCE.init({
					theme : "advanced",
					mode : "exact",
					elements : "_textarea",
					theme_advanced_toolbar_location : "top",
					theme_advanced_toolbar_align : "left",
					valid_elements : "pre[name]"
				});
			</script>
		}
	end
	
	def render_create_post
		partial(:create_post)
	end
	
	def render_paging_title(posts)
		(posts.current_page.to_s == posts.page_count.to_s) ? "" : "More"
	end
	
	def render_paged_link(posts, number, tagged)
		unless number.to_s == posts.current_page.to_s
			return link_to("#{number}", "/posts?page=#{number}") if !tagged
			return link_to("#{number}", "/posts/tag/#{params['tag']}?page=#{number}") if tagged
		else
			return "#{number}"
		end
	end
	
	def render_paging(posts, tagged)
		return if posts.blank? || posts.page_count.to_i <= 1
		partial(:paging, :locals => {:posts => posts, :tagged => tagged })
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
	
	def render_post(post)
		partial(:post, :locals => {:post => post})
	end
	
	def partial(name, options={})
  	erb(name, options.merge(:layout => false))
  end

	def link_to_randomize_tag_size(tag)
		font = [8, 12, 14, 18, 20, 24].sort_by {rand}.first
		link_to(tag, "/posts/tag/#{tag}", :style => "font-size:#{font}px;")
	end
	
	def render_captcha(html_options={})
		remote_image_tag(captcha_url(), html_options)
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
