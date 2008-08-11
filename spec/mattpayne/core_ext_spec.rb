require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe "Core Extensions" do
	
  describe "Array additions" do
		
    it "should include the CollectionExtensions and CollectionExtensions::InstanceMethods module" do
      Array.included_modules.should be_include(CollectionExtensions)
      Array.included_modules.should be_include(CollectionExtensions::InstanceMethods)
    end
		
    it "should respond_to? not_empty?" do
      [].should respond_to(:"not_empty?")
    end
		
    it "should respond true to not_empty? when the array contains stuff" do
      ["a", "b"].should be_not_empty
    end
		
    it "should respond false to not_empty? when the array is empty" do
      [].should_not be_not_empty
    end
		
    it "should respond_to? shuffle" do
      [].should respond_to(:shuffle)
    end
		
    it "should shuffle itself somewhat randomly and return a new array" do
      ordered = ["a", "b", "c", "d"]
      shuffled = ordered.shuffle
      shuffled.object_id.should_not == ordered.object_id
    end
		
    it "should return an array with a single element if told to shuffle a single element array" do
      ordered = ["a"]
      shuffled = ordered.shuffle
      ordered.first.should == shuffled.first
    end
		
    it "should return an empty array when shuffling an empty array" do
      ordered = []
      shuffled = ordered.shuffle
      shuffled.should be_empty
    end
		
  end
	
  describe "Hash extensions" do
	
    it "should include the CollectionExtensions and CollectionExtensions::InstanceMethods module" do
      Hash.included_modules.should be_include(CollectionExtensions)
      Hash.included_modules.should be_include(CollectionExtensions::InstanceMethods)
    end
		
    it "should respond_to? not_empty?" do
      {}.should respond_to(:"not_empty?")
    end
		
    it "should respond true to not_empty? when the hash contains stuff" do
      {"a" => "x", "b" => "y"}.should be_not_empty
    end
		
    it "should respond false to not_empty? when the hash is empty" do
      {}.should_not be_not_empty
    end
		
    it "should respond_to? to_html_options" do
      {}.should respond_to(:to_html_options)
    end
		
    it "should be able to convert itself to a string representing html element attributes" do
      opts = {:class => "aClass", :align => "left"}
      opts.to_html_options.should include("class=\"aClass\"")
      opts.to_html_options.should include("align=\"left\"")
    end
		
    it "should return an empty string from to_html_options if it is empty" do
      {}.to_html_options.should == ""
    end
		
  end
	
  describe "Object extensions" do
		
    it "should respond_to? blank?" do
      o = Object.new
      o.should respond_to(:"blank?")
    end
		
    it "should correctly report a nil object as blank" do
      o = nil
      o.should be_blank
    end
		
    it "should correctly report and empty string as blank" do
      "".should be_blank		
    end
		
    it "should correctly report an empty array as blank" do
      [].should be_blank		
    end
		
    it "should correctly report an empty hash as blank" do
      {}.should be_blank
    end
		
  end
	
  describe PagingArray do
		
    before(:each) do
      @a = PagingArray.new(12, 20)
    end
		
    it "should respond_to? current_page" do
      @a.should respond_to(:current_page)
    end
		
    it "should respond_to? page_count" do
      @a.should respond_to(:page_count)
    end
		
  end
	
  describe "String extensions" do
		
    it "should respond_to? capitalize" do
      "".should respond_to(:capitalize)
    end
		
    it "should properly capitalize a non-capitalized word" do
      "monkey".capitalize.should == "Monkey"
    end
		
    it "should handle an empty string" do
      "".capitalize.should == ""
    end
		
  end
	
end
