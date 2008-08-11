require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe MattPayne::BlogToRss do
  include MattPayne::BlogToRss
	
  it "should define version as 2.0" do
    MattPayne::BlogToRss::VERSION.should == "2.0"
  end
	
  it "should respond_to? to_rss" do
    self.should respond_to(:to_rss)
  end
	
  it "should call self.all in order to get all items" do
    self.should_receive(:all).and_return([])
    self.to_rss
  end
	
  it "should return a string string of xml representing the rss" do
    self.should_receive(:all).and_return([])
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
	
end
