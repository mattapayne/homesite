require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe MattPayne::Database do
	
  class UtilClass
    include MattPayne::Database::Utils
  end
	
  class TestClass
    include MattPayne::Database
		
    def self.metaclass
      class << self; self; end
    end
		
  end
	
  describe "Database" do
	
    it "should extend MattPayne::Database::Connection when included" do
      TestClass.metaclass.included_modules.should be_include(MattPayne::Database::Connection)
    end
	
    it "should respond_to? with_database" do
      TestClass.should respond_to(:with_database)
    end
	
  end
	
  describe "Utils" do
	
    before(:each) do
      @util = UtilClass.new
    end
	
    it "should respond_to? create_schema" do
      @util.should respond_to(:create_schema)
    end
	
    it "should respond_to? create_comments" do
      @util.should respond_to(:create_comments)		
    end
		
    it "should respond_to? create_posts" do
      @util.should respond_to(:create_posts)
    end
		
    it "should respond_to? create_app_settings" do
      @util.should respond_to(:create_app_settings)
    end


  end
	
end
