require 'rss/maker'

module MattPayne

	module BlogToRss
	
		VERSION = "2.0"
		
		def to_rss
			return unless respond_to?(:all)
			posts = self.all
			content = RSS::Maker.make(VERSION) do |m|
				m.channel.title = "Matt Payne Consulting RSS feed"
				m.channel.link = "http://mattpayne.ca:4567"
				m.channel.description = "Matt Payne Consulting Blog Posts"
				m.items.do_sort = true # sort items by date
				posts.each do |p|
					i = m.items.new_item
					i.title = p.title
					i.description = p.body
					i.link = "http://www.mattpayne.ca:4567/post/#{p.id}"
					i.date = p.created_at
				end
			end
			content.to_s
		end
		
	end
	
end
