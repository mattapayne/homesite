require 'rss/maker'

module MattPayne

  module BlogToRss
	
    VERSION = "2.0"
    TITLE = "Matt Payne Consulting RSS feed"
    LINK = "http://mattpayne.ca/blog"
    DESCRIPTION = "Matt Payne Consulting Blog Posts"
		
    def to_rss
      return unless respond_to?(:all)
      items = self.all
      content = RSS::Maker.make(BlogToRss::VERSION) do |m|
        m.channel.title = BlogToRss::TITLE
        m.channel.link = BlogToRss::LINK
        m.channel.description = BlogToRss::DESCRIPTION
        m.items.do_sort = true # sort items by date
        items.each do |p|
          i = m.items.new_item
          i.title = p.title
          i.description = p.body
          i.link = "#{BlogToRss::LINK}/post/#{p.slug}"
          i.date = p.created_at
        end
      end
      content.to_s
    end
		
  end
	
end
