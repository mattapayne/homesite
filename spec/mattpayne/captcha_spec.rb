require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe MattPayne::Captcha do
  
  before(:each) do
    @cap = MattPayne::Captcha.new
  end
	
  def session
    @session ||= {}
  end
	
  def valid_supplied_captcha
    @valid ||= "bphign"
  end
	
  def captcha_key
    @key ||= "dffsdf"
  end
	
  describe "valid?" do
		
    it "should return true if the supplied captcha is valid" do
      MattPayne::Captcha.valid?(captcha_key, valid_supplied_captcha).should be_true
    end
		
    it "should return false if the supplied captcha is invalid" do
      MattPayne::Captcha.valid?("somthing invalid", valid_supplied_captcha).should be_false
    end
		
  end
	
  describe "captcha_url" do
		
    it "should return a url that includes the current captcha key" do
      url = @cap.captcha_url(captcha_key)
      url.should =~ /^http:\/\/image.captchas.net\/\?client=.*#{captcha_key}$/
    end
		
    it "should ask the Config for the captcha username" do
      MattPayne::Config.should_receive(:captcha_username).and_return("AUserName")
      @cap.captcha_url(captcha_key)
    end
		
  end
	
  describe "generate_random" do
		
    it "should generate a random 6 character string when no size is specified" do
      @cap.generate_random.should have(6).items
    end
		
    it "should generate a random N character string if a size of N is specified" do
      @cap.generate_random(10).should have(10).items
    end 
		
  end
	
end
