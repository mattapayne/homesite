require 'net/http'
require 'uri'

module MattPayne
  
  module Akismet
  
    COMMENT_CHECK_URL = "rest.akismet.com/1.1/comment-check"
    
    def self.valid_comment?(comment, data)
      post_data = Akismet.generate_akismet_post_data(comment, data)
      result = Akismet.akismet_post(post_data)
      result.downcase == "false"
    end
    
    private
    
    def self.generate_akismet_post_data(comment, post_data)
      blog = post_data[:blog] || "http://mattpayne.ca/blog"
      user_ip = post_data[:ip]
      user_agent = post_data[:user_agent]
      referrer = post_data[:referrer]
      permalink = "#{blog}/post/#{comment.post.slug}"
      comment_type = post_data[:comment_type] || "comment"
      return {
        "blog" => blog, "user_ip" => user_ip, "user_agent" => user_agent,
        "referrer" => referrer, "permalink" => permalink, "comment_type" => comment_type,
        "comment_author" => comment.username, "comment_author_email" => comment.email,
        "comment_author_url" => comment.website, "comment_content" => comment.comment }
    end
    
    def self.akismet_subdomain
      return "http://#{MattPayne::Config.akismet_key}.#{Akismet::COMMENT_CHECK_URL}"
    end
    
    def self.akismet_post(post_data)
      return Net::HTTP.post_form(URI.parse(Akismet.akismet_subdomain), post_data).body
    end
    
  end
  
end