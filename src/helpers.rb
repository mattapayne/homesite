module MattPayne

  module Helpers
	
    include MattPayne::HtmlTags
    include Rack::Utils
    include MattPayne::Security
		
    @@tag_font_map = {1 => "8px", 2 => "12px", 3 => "14px", 4 => "18px", 5 => "20px", 6 => "24px"}
		
    alias_method :h, :escape_html
    
    def tags_as_links(tags)
      return if tags.blank?
      urls = tags.split(" ").inject(String.new) do |s, t|
        s << link_to("#{t}", "/blog/posts/tagged-as/#{t}")
        s << ", "
        s
      end
      urls.chomp!(", ")
      urls
    end
		
    def self.font_for_tag(tag)
      max = @@tag_font_map.max
      return max.last if tag.count >= max.first
      return @@tag_font_map[tag.count]
    end
    
    def render_gmh
      #http://maps.google.ca/maps?f=q&hl=en&geocode=&q=139+brighton+st+waterloo&sll=43.471258,-80.518501&sspn=0.010885,0.018775&ie=UTF8&z=16&iwloc=addr
      %{
        <script src="http://maps.google.com/maps?file=api&amp;v=2&amp;key=#{MattPayne::Config.google_maps_api_key}"
          type="text/javascript"></script>
          <script type="text/javascript">

          //<![CDATA[

          function load() {
            if (GBrowserIsCompatible()) {
              var address = "<p>139 Brighton St. Unit 6b<br />Waterloo, Ontario, Canada<br />N2J 4Z5<br />(519) 573-2888<br /><a href='mailto:paynmatt@gmail.com>Email MPC</a></p>";
              var map = new GMap2(document.getElementById("map"));
              var ctl = new GSmallMapControl();
              map.addControl(ctl);
              var point = new GLatLng(43.471258, -80.51850);
              map.setCenter(point, 15);
              marker = new GMarker(point);
              map.addOverlay(marker);
              GEvent.addListener(marker, "click", function() {
                map.openInfoWindowHtml(point, address);
              });
              map.openInfoWindow(map.getCenter(), address);
            }
          }

          //]]>
        </script>
      }

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
    
    def render_admin_menu
      partial(:admin_menu)
    end
	
    def render_paging_title(posts)
      return unless posts
      (posts.current_page.to_s == posts.page_count.to_s) ? "" : "More"
    end
	
    def render_paged_link(posts, number, tagged=false, searched=false)
      return unless posts
      unless number.to_s == posts.current_page.to_s
        if searched
          return link_to("#{number}", "/blog/posts/search?query=#{params['query']}&page=#{number}")
        elsif tagged
          return link_to("#{number}", "/blog/posts/tagged-as/#{params['tag']}?page=#{number}")
        else
          return link_to("#{number}", "/blog?page=#{number}")
        end
      else
        return "#{number}"
      end
    end
	
    def render_paging(posts, tagged=false, searched=false)
      return if posts.blank? || posts.page_count.to_i <= 1
      partial(:paging, :locals => {:posts => posts, :tagged => tagged, :searched => searched })
    end
	
    def render_github_repos(repos)
      partial(:github_repositories, :locals => {:repos => repos})
    end
    
    def render_post_search
      partial(:search)
    end
    
    def render_defensio
      partial(:defensio)
    end
	
    def render_tumblr_posts(posts)
      partial(:tumblr_posts, :locals => {:posts => posts})
    end
	
    def render_tags(tags)
      partial(:tags, :locals => {:tags => tags})
    end
	
    def render_post(post, singular=false)
      partial(:post, :locals => {:post => post, :singular => singular})
    end
	
    def partial(name, options={})
      erb(name, options.merge(:layout => false))
    end
		
    def link_to_rss_feed
      image_link_to("feed-icon-14x14.png", "/blog/posts.rss", {}, {})
    end

    def link_to_randomize_tag_size(tag)
      link_to("#{tag.tag} (#{tag.count})", "/blog/posts/tagged-as/#{tag.tag}", :style => "font-size:#{MattPayne::Helpers.font_for_tag(tag)}")
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
