module MattPayne

	module Helpers
	
		include MattPayne::HtmlTags
		include Rack::Utils
		include MattPayne::Captcha
		include MattPayne::Security
		
		@@tag_font_map = {1 => "8px", 2 => "12px", 3 => "14px", 4 => "18px", 5 => "20px", 6 => "24px"}
		
		alias_method :h, :escape_html
		
		def self.font_for_tag(tag)
			max = @@tag_font_map.max
			return max.last if tag.count >= max.first
			return @@tag_font_map[tag.count]
		end
		
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
						extended_valid_elements : "pre[name|class]"
					});
				</script>
			}
		end
	
		def render_create_post
			partial(:create_post)
		end
	
		def render_paging_title(posts)
			return unless posts
			(posts.current_page.to_s == posts.page_count.to_s) ? "" : "More"
		end
	
		def render_paged_link(posts, number, tagged)
			return unless posts
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
		
		def link_to_rss_feed
			image_link_to("feed-icon-14x14.png", "/posts/posts.rss", {}, {:style => "margin-bottom:-3px;"})
		end

		def link_to_randomize_tag_size(tag)
			link_to("#{tag.tag} (#{tag.count})", "/posts/tag/#{tag.tag}", :style => "font-size:#{MattPayne::Helpers.font_for_tag(tag)}")
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
	
end
