require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe MattPayne::Helpers do
	include MattPayne::Helpers
	
	describe "render_paging_title" do
		
		it "should return nil if the posts object is nil" do
			self.render_paging_title(nil).should be_nil
		end
		
		it "should return an empty string if the current page equals the total page count" do
			posts = PagingArray.new(1, 1)
			self.render_paging_title(posts).should == ""
		end
		
		it "should return 'More' if the current page is not equal to the total page count" do
			posts = PagingArray.new(1, 15)
			self.render_paging_title(posts).should == "More"
		end
		
	end
	
	describe "render_paged_link" do
		
		it "should return a simple string instead of a link if the page is equal to the current number" do
			self.render_paged_link(PagingArray.new(2, 2), 2, true).should == "2"
		end
		
		it "should return nil if the posts array is nil" do
			self.render_paged_link(nil, nil, nil).should be_nil
		end
		
		it "should render a proper post link if number is not equal to current page and it's not tagged" do
			self.render_paged_link(PagingArray.new(1, 5), 3, false).should == "<a href=\"/posts?page=3\" >3</a>"
		end
		
		it "should render a proper post link if number is not equal to current page and it is tagged" do
			self.stub!(:params).and_return({'tag' => "something"})
			self.render_paged_link(PagingArray.new(1, 5), 3, true).should == "<a href=\"/posts/tag/something?page=3\" >3</a>"
		end
		
	end
	
	describe "render_paging" do
		
		it "should return nil if the posts array is empty" do
			self.render_paging(PagingArray.new(1, 5), false).should be_nil
		end
		
		it "should return nil if the page count == 1" do
			a = PagingArray.new(1, 1)
			a << Post.new
			self.render_paging(a, false).should be_nil
		end
		
		it "should return nil if the page count < 1" do
			a = PagingArray.new(0, 1)
			a << Post.new
			self.render_paging(a, false).should be_nil
		end
		
	end

end
