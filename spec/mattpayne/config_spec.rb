require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe MattPayne::Config do

  before(:each) do
    #Because this is probably read and set in a different test, make sure it's reset to nil
    MattPayne::Config.send(:class_variable_set, "@@config", nil)
    MattPayne::Config.send(:class_variable_set, "@@cache", {})
  end
	
  it "should get the current environment from Sinatra" do
    Sinatra.application.options.should_receive(:env).and_return("test")
    MattPayne::Config.config
  end
	
  it "should use the Setting class to retrieve app settings" do
    settings = Setting.all
    Setting.should_receive(:all).and_return(settings)
    MattPayne::Config.config
  end
	
  it "should only load settings for the current environment" do
    Sinatra.application.options.stub!(:env).and_return("test")
    MattPayne::Config.config.each {|cfg| cfg.environment.should == "test"}
  end
	
  it "should cache settings" do
    MattPayne::Config.should_receive(:retrieve_from_cache).with(:github_url).at_least(2).times
    MattPayne::Config.should_receive(:store_in_cache).at_least(1).times
    MattPayne::Config.github_url
  end
  
  it "should retrieve the connection using the ConnectionStringGetter class if its not cached" do
    MattPayne::Config::ConnectionStringGetter.should_receive(:get).and_return("blah")
    MattPayne::Config.connection_string.should == "blah"
  end
  
  it "should attempt to get the connection string from the cache" do
    MattPayne::Config.should_receive(:retrieve_from_cache).at_least(2).times.with(:connection_string)
    MattPayne::Config.connection_string
  end
  
  it "should place the connection string in the cache if its not already there" do
    MattPayne::Config.stub!(:retrieve_from_cache).with(:connection_string).and_return(nil)
    MattPayne::Config.should_receive(:store_in_cache)
    MattPayne::Config.connection_string
  end
  
  it "should not read from the config file if the connection string is already cached" do
    MattPayne::Config.should_not_receive(:store_in_cache)
    MattPayne::Config.should_receive(:retrieve_from_cache).with(:connection_string).and_return("blah")
    MattPayne::Config.connection_string
  end
end
