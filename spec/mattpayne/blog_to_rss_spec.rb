require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe MattPayne::BlogToRss do
  include MattPayne::BlogToRss
	
  it "should respond_to? to_rss" do
    self.should respond_to(:to_rss)
  end
	
  it "should call self.all in order to get all items" do
    self.should_receive(:all).and_return([])
    self.to_rss
  end
	
  it "should return a string string of xml representing the rss" do
    self.stub!(:all).and_return([])
    self.to_rss.should_not be_nil
  end
	
  it "should return nil if self does not respond_to? all" do
    self.stub!(:respond_to?).with(:all).and_return(false)
    self.to_rss.should be_nil
  end
	
  it "should use RSS::Maker to create the rss" do
    self.should_receive(:all).and_return([])
    RSS::Maker.should_receive(:make).with(MattPayne::BlogToRss::VERSION)
    self.to_rss
  end
  
  it "the resulting rss should contain a version of 2" do
    self.stub!(:all).and_return([])
    self.to_rss().should =~ /(<rss version="2.0")+/
  end
  
  it "the resulting rss should contain a title" do
    self.stub!(:all).and_return([])
    self.to_rss().should =~ /(<title>.+<\/title>)+/
  end
  
  it "the resulting rss should contain a link" do
    self.stub!(:all).and_return([])
    self.to_rss().should =~ /(<link>http:\/\/.+<\/link>)+/
  end
  
  it "the resulting rss should contain a description" do
    self.stub!(:all).and_return([])
    self.to_rss().should =~ /(<description>.+<\/description>)+/
  end
  
  describe "with items" do
    
    def items
      @items ||
        (@items = []
          1.upto(10) do |i| 
          @items << Post.new(:title => "Post #{i}", 
            :body => "This is the body of Post #{i}.", 
            :tags => "#{i}")
        end)
      @items
    end
    
    it "the resulting rss should include the proper number of items" do
      self.stub!(:all).and_return(items)
      self.to_rss().scan(/<item>/).should have(10).items
    end
    
  end
	
end
