module MattPayne
  
  module ControllerHelpers
    
    private
    
    def log_valid_comment(comment)
       MattPayne::AppLogger.info("VALID COMMENT DETECTED FROM #{request.env["REMOTE_ADDR"]}. The comment refers to post: #{comment.post.slug}.")
    end
    
    def log_spam(comment)
      MattPayne::AppLogger.warn(generate_spam_log_message(comment))
    end
    
    def generate_spam_log_message(comment)
      %{
        SPAM COMMENT DETECTED FROM: #{request.env["REMOTE_ADDR"]}. The comment
        refers to post: #{comment.post.slug}.
        DEFENSIO VALUES: Spam? #{comment.spam?}, Spaminess: #{comment.spaminess}
      }
    end
    
    def send_new_comment_mail(comment)
      options = {
        :username => MattPayne::Config.gmail_username,
        :password => MattPayne::Config.gmail_password,
        :subject => "A New Comment Has Been Submitted",
        :body => %{#{comment.username} has submitted a comment about: #{comment.post.title}
                  #{comment.comment}}
      }
      begin
        MattPayne::GMailer.send(options)
      rescue Exception => e
        MattPayne::AppLogger.error("Attempting to send new comment email, but an error occurred: #{e}")
      end
    end
    
    def submit_post(post)
      if [:test, :development].include?(Sinatra.application.options.env)
        require 'ostruct'
        return OpenStruct.new({
            :status => "success"
          })
      end
      begin
        RDefensio::API.announce_article(
          {
            "article-author" => "Matt Payne",
            "article-author-email" => "paynmatt@gmail.com",
            "article-title" => post.title, "article-content" => post.body,
            "permalink" => "#{RDefensio::API.owner_url}/post/#{post.slug}"
          }
        )
      rescue Exception => e
        MattPayne::AppLogger.error("Attempting to announce new article to Defension, but an error occurred: #{e}")
      end
    end
    
    def submit_comment(comment, spam=false, ham=false)
      if [:test, :development].include?(Sinatra.application.options.env)
        require 'ostruct'
        return OpenStruct.new({
            :signature => "dfsdfsdf",
            :spam => false,
            :spaminess => 0.03,
            :api_version => "1.2"
          })
      end
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
      begin
        RDefensio::API.audit_comment(args)
      rescue Exception => e
        MattPayne::AppLogger.error("Attempting to audit a comment, but an error occurred: #{e}")
      end
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
      sleep_time = options[:sleep] || false
      if sleep_time
        sleep(sleep_time)
      end
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
