module MattPayne
  
  module ControllerHelpers
    
    private
    
    def submit_post(post)
      RDefensio::API.announce_article(
        {
          "article-author" => "Matt Payne",
          "article-author-email" => "paynmatt@gmail.com",
          "article-title" => post.title, "article-content" => post.body,
          "permalink" => "#{RDefensio::API.owner_url}/post/#{post.slug}"
        }
      )
    end
    
    def submit_comment(comment, spam=false, ham=false)
      args =  {
        "user-ip" => user_ip, "article-date" => comment.post.created_at, 
        "comment-author" => comment.username, "comment-type" => "comment",
        "comment-content" => comment.comment, "comment-author-email" => comment.email,
        "permalink" => "#{RDefensio::API.owner_url}/post/#{comment.post.slug}", "referrer" => user_referrer,
        "user-logged-in" => logged_in?.to_s, "trusted-user" => logged_in?.to_s
      }
      if spam
        args["test-force"] = "spam,0.6700"
      elsif ham
        args["test-force"] = "ham,0.6700"
      end
      RDefensio::API.audit_comment(args)
    end

    def blog_url
      Sinatra.application.development? ? "http://localhost:4567/blog" : nil
    end
    
    def user_ip
      request.env["REMOTE_ADDR"]
    end
    
    def user_referrer
      request.env["HTTP_REFERER"]
    end
    
    def user_agent
      request.env["HTTP_USER_AGENT"]
    end
    
    def ensure_param(condition, message)
      unless condition
        @error_message = message
      end
    end
    
    def raise_post_not_found(id)
      raise Sinatra::NotFound.new("Could not find a post identified by: #{id}")
    end

    def load_blog_variables
      @tags ||= Post.all_tags
      @tumblr_posts ||= MattPayne::Tumblr.posts
      @github_repos ||= MattPayne::GitHub.repositories
    end

    def for_simple_action(options={}, &block)
      options = {:action => "home", :render_gmh => false}.merge(options)
      @action = options[:action]
      @title = " - #{options[:action].capitalize}"
      @render_gmh = options[:render_gmh]
      block.call if block_given?
    end

    def for_blog_related_action(options={}, &block)
      options = {
        :action => "blog", :rte_required => false, 
        :title => " - Blog", :requires_highlighting => false,
        :tagged => false, :searched => false, :secure => false
      }.merge(options)
      if options.key?(:secure) && options[:secure] == true
        require_login
      end
      load_blog_variables
      @action = options[:action]
      @title = options[:title]
      @rte_required = options[:rte_required]
      @requires_highlighting = options[:requires_highlighting]
      @tagged = options[:tagged]
      @searched = options[:searched]
      block.call if block_given?
    end
    
  end
  
end
