require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe MattPayne::Captcha do
  include MattPayne::Captcha
	
  def session
    @session ||= {}
  end
	
  def valid_supplied_captcha
    @valid ||= "bphign"
  end
	
  def captcha_key
    @key ||= "dffsdf"
  end
	
  describe "captcha_valid?" do
		
    before(:each) do
      self.session[:captcha] = captcha_key
    end
		 
    it "should delete the captcha key from the session" do
      self.captcha_valid?(valid_supplied_captcha)
      self.session.should be_empty
    end
		
    it "should return true if the supplied captcha is valid" do
      self.captcha_valid?(valid_supplied_captcha).should be_true
    end
		
    it "should return false if the supplied captcha is invalid" do
      self.captcha_valid?("somthing invalid").should be_false
    end
		
  end
	
  describe "captcha_url" do
		
    it "should insert an new captcha key into the session" do
      url = self.captcha_url
      self.session[:captcha].should_not be_nil
    end
		
    it "should return a url that includes the current captcha key" do
      url = self.captcha_url
      url.should =~ /^http:\/\/image.captchas.net\/\?client=.*#{self.session[:captcha]}$/
    end
		
    it "should ask the Config for the captcha username" do
      MattPayne::Config.should_receive(:captcha_username).and_return("AUserName")
      self.captcha_url
    end
		
  end
	
  describe "generate_captcha_text" do
		
    it "should generate a random 6 character string when no size is specified" do
      self.generate_captcha_text.should have(6).items
    end
		
    it "should generate a random N character string if a size of N is specified" do
      self.generate_captcha_text(10).should have(10).items
    end 
		
  end
	
end
