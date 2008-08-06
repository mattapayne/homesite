require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe MattPayne::Tumblr do
	include MattPayne::Tumblr

	def response_body
		<<-eos
			<tumblr version="1.0">
				<tumblelog name="mpayne" timezone="US/Eastern" title="Coding with headphones">
				<feeds>
					<feed id="235529" url="http://twitter.com/statuses/user_timeline/15119954.rss" import-type="regular-no-title" 						next-update-in-seconds="1227" title="Twitter / mapayne" error="true" error-text="true"/>
					</feeds>
				</tumblelog>
				<posts start="0" total="31" type="regular">
					<post id="44888585" url="http://mpayne.tumblr.com/post/44888585" type="regular" date-gmt="2008-08-06 04:03:42 						GMT" date="Wed, 06 Aug 2008 00:03:42" unix-timestamp="1217995422">
						<regular-title>I've beta launched my new site</regular-title>
						<regular-body>I&#8217;ve been wanting to get a professional site up for a while now, so I finally went ahead 								and did it. It&#8217;s <a target="_blank" href="http://mattpayne.ca:4567">here</a>. It is currently in 								beta mode while I so some server configuration and some testing. At some point soon, I hope to launch it 								for real.</regular-body>
					</post>
					<post id="44174383" url="http://mpayne.tumblr.com/post/44174383" type="regular" date-gmt="2008-07-31 06:53:49 						GMT" date="Thu, 31 Jul 2008 02:53:49" unix-timestamp="1217487229">
						<regular-title>Wow, is going back to Java painful!</regular-title>
						<regular-body><p>So I decided today to do some coding in Java. I&#8217;ve always wanted to build a feed 							reader - mainly to become more familiar with RSS and ATOM, not so much because I need a feed reader.</p>
							<p>After so much Ruby work, Java is really clunky feeling. I still like it, I suppose, but I miss blocks. 							I especially miss the unless keyword, for some reason.</p>
							<p>On the plus side, I was able to dig up a couple of BDD frameworks for Java:</p>
							<p><a target="_blank" title="JDave" href="http://www.jdave.org">JDave</a> and <a target="_blank" 								title="JBehave" href="http://jbehave.org">JBehave</a>. I haven&#8217;t gotten the opportunity to do much 								with either yet, but I will shortly.</p></regular-body>
					</post>
				</posts>
			</tumblr>
		eos
	end
	
	def stub_response(raise_error=false)
		@response = mock("Response")
		self.stub!(:open).with(MattPayne::Config.tumblr_url).and_return(@response)
		@response.stub!(:read).and_return(response_body) unless raise_error
		@response.stub!(:read).and_raise(RuntimeError) if raise_error
	end
	
	it "should respond_to? tumblr_posts" do
		self.should respond_to(:tumblr_posts)
	end
	
	it "should return an empty hash if opening the url fails" do
		self.should_receive(:open).with(MattPayne::Config.tumblr_url).and_raise(RuntimeError)
		self.tumblr_posts.should be_empty
	end
	
	it "should return an empty hash if reading the response fails" do
		stub_response(true)
		self.tumblr_posts.should be_empty
	end
	
	it "should return an array of hashes, each representing a post" do
		stub_response(false)
		self.tumblr_posts.should have(2).items
	end
	
	it "should return posts that all have a title" do
		stub_response(false)
		posts = self.tumblr_posts
		posts.each { |p| p["regular-title"].should_not be_nil }
	end
	
	it "should return posts that all have a url" do
		stub_response(false)
		posts = self.tumblr_posts
		posts.each {|p| p["url"].should_not be_nil }
	end
	
end
