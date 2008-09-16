require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe MattPayne::GitHub do
  
  def response_body
    <<-eos
      <user>
        <company>Matt Payne Consulting (MPC)</company>
        <name>Matt Payne</name>
        <repositories type="array">
        <repository>
        <watchers type="integer">1</watchers>
        <description>
        Simple plugin that makes creates a money field for any integer field on an ActiveRecord model
        </description>
        <name>actsasvalued</name>
        <owner>mattapayne</owner>
        <private type="boolean">false</private>
        <url>http://github.com/mattapayne/actsasvalued</url>
        <forks type="integer">0</forks>
        </repository>
        <repository>
        <watchers type="integer">1</watchers>
        <description>
        Allows an ActiveRecord model to specify that one attribute can provide data for another if its blank.
        </description>
        <name>actsasfriendlynamed</name>
        <owner>mattapayne</owner>
        <private type="boolean">false</private>
        <url>http://github.com/mattapayne/actsasfriendlynamed</url>
        <forks type="integer">0</forks>
        </repository>
        <repository>
        <watchers type="integer">1</watchers>
        <description>
        A Ruby on Rails plugin to provide easy access to the JamBase live concert search API.
        </description>
        <name>jambase4rails</name>
        <owner>mattapayne</owner>
        <private type="boolean">false</private>
        <url>http://github.com/mattapayne/jambase4rails</url>
        <forks type="integer">0</forks>
        </repository>
        <repository>
        <watchers type="integer">4</watchers>
        <description>
        A Ruby on Rails plugin for accessing the Tumblr API
        </description>
        <name>tumblr4rails</name>
        <owner>mattapayne</owner>
        <private type="boolean">false</private>
        <url>http://github.com/mattapayne/tumblr4rails</url>
        <forks type="integer">0</forks>
        </repository>
        <repository>
        <watchers type="integer">1</watchers>
        <description>Nothing to see here</description>
        <name>homesite</name>
        <owner>mattapayne</owner>
        <private type="boolean">false</private>
        <url>http://github.com/mattapayne/homesite</url>
        <forks type="integer">0</forks>
        </repository>
        <repository>
        <watchers type="integer">1</watchers>
        <description>My homesite in Django</description>
        <name>homesite_py</name>
        <owner>mattapayne</owner>
        <private type="boolean">false</private>
        <url>http://github.com/mattapayne/homesite_py</url>
        <forks type="integer">0</forks>
        </repository>
        <repository>
        <watchers type="integer">1</watchers>
        <description>Nothing</description>
        <name>datamigrator</name>
        <owner>mattapayne</owner>
        <private type="boolean">false</private>
        <url>http://github.com/mattapayne/datamigrator</url>
        <forks type="integer">0</forks>
        </repository>
        </repositories>
        <blog>http://mattpayne.ca/blog</blog>
        <login>mattapayne</login>
        <email>paynmatt@gmail.com</email>
        <location>Waterloo, Ontario, Canada</location>
    </user>
    eos
  end
  
  def stub_response(raise_error=false)
    @response = mock("Response")
    MattPayne::GitHub.stub!(:open).with(MattPayne::Config.github_url).and_return(@response)
    @response.stub!(:read).and_return(response_body) unless raise_error
    @response.stub!(:read).and_raise(RuntimeError) if raise_error
  end
  
  it "should respond_to? repositories" do
    MattPayne::GitHub.should respond_to(:repositories)
  end
   
  it "should return an empty hash if opening the url fails" do
    MattPayne::GitHub.should_receive(:open).with(MattPayne::Config.github_url).and_raise(RuntimeError)
    MattPayne::GitHub.repositories.should be_empty
  end
	
  it "should return an empty hash if reading the response fails" do
    stub_response(true)
    MattPayne::GitHub.repositories.should be_empty
  end
  
  it "should return an array of OpenStructs, each representing a repository" do
    stub_response(false)
    MattPayne::GitHub.repositories.should have(7).items
  end
  
  it "should return repositories that all have a name" do
    stub_response(false)
    repos = MattPayne::GitHub.repositories
    repos.each {|r| r.name.should_not be_nil }
  end
  
  it "should return repositories that all have an url" do
    stub_response(false)
    repos = MattPayne::GitHub.repositories
    repos.each {|r| r.url.should_not be_nil }
  end
  
end
