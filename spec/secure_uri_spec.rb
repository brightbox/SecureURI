require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SecureURI" do

  it "should work" do

    url = URI.parse("http://caius.name/foo?bar=sed")

    url.secure?.should == false
    url.valid?.should == false

    str = url.secure!

    str.should =~ /hash/

    url.secure?.should == true
    url.valid?.should == true

    url.query = (url.query + "&thing=nothing")

    url.secure?.should == true
    url.valid?.should == false

    url.secure!

    url.secure?.should == true
    url.valid?.should == true

  end

  before do
    @url = "http://example.com/path?query=string"
    @uri = URI.parse(@url)

    @secure_url = "http://example.com/path?query=string&hash=ZOMG-HASH"
    @secure_uri = URI.parse(@secure_url)

    SecureURI.salt = "my lovely salt"
  end

  it "should be a URI" do
    @uri.should be_a_kind_of(URI)
  end

  it "should turn into a secure url" do
    @uri.query.should_not =~ /hash=/
    @uri.secure!
    @uri.query.should =~ /hash=/
  end

  it "should not be a secure url" do
    @uri.should_not be_secure
  end

  it "should be a secure url" do
    @secure_uri.should be_secure
  end

  it "should validate as a secure uri" do
    hash_obj = mock(BCrypt::Password)
    hash_obj.should_receive(:==).and_return(true)
    BCrypt::Password.should_receive(:new).and_return(hash_obj)

    @secure_uri.should be_valid
  end

  it "should fail validation as a secure url" do
    @secure_uri.should_not be_valid
  end

  it "should update the hash if the query changes" do
    @secure_uri.query += "&foo=bar"
    @secure_uri.query.should =~ /foo=bar/
    @secure_uri.query.should =~ /hash=/
    old_hash = @secure_uri.send(:hash_string)

    @secure_uri.secure!

    @secure_uri.query.should =~ /hash=/
    @secure_uri.send(:hash_string).should_not == old_hash
  end

  it "should secure a url" do
    @uri.query.should_not =~ /hash=/
    @uri.secure!

    @uri.query.should =~ /hash=/
    @uri.should be_secure
    @uri.should be_valid
  end

  it "should update a secure url" do
    @secure_uri.query.should =~ /hash=/
    q = @secure_uri.query.dup

    @secure_uri.secure!

    @secure_uri.query.should =~ /hash=/
    q.should_not == @secure_uri.query
  end

  describe "hasher" do

    it "should use bcrypt by default" do
      SecureURI.class_eval("@@hasher").should == "SecureURI::BCryptHasher"
    end

    it "should let you set your own hasher class" do
      SecureURI.hasher = "FooBarSed"

      SecureURI.class_eval("@@hasher").should == "FooBarSed"
    end

    describe "class" do
      it "should set hasher when subclassed" do
        class HasherSub < SecureURI::Hasher
        end
        
        SecureURI.class_eval("@@hasher").should == "HasherSub"
      end
    end
  end
end
