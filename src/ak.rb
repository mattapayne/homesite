require 'akismet'

module MattPayne
  
  module AK
  
    BLOG = "http://mattpayne.ca/blog"
    
    def self.valid_comment?(comment, data)
      permalink = "#{AK::BLOG}/post/#{comment.post.slug}"
      #If check comment returns true, the comment is spam, otherwise, it's not spam.
      result = akismet_api.commentCheck(
        data[:ip], data[:user_agent], data[:referrer], permalink, data[:comment] || "comment", 
        comment.username, comment.email, comment.website, comment.comment, {:blog => data[:blog] || BLOG}
      )
      return result != true
    end
   
    private
    
    def self.akismet_api
      @@akismet ||= Akismet.new(MattPayne::Config.akismet_key, AK::BLOG)
    end
  end
  
end