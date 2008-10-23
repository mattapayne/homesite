module MattPayne
  
  module ControllerHelpers
    
    private

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
