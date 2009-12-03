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

    # todo: change to set the salt for the SHA256Hasher
    # SecureURI.salt = "my lovely salt"
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
    SecureURI::SHA256Hasher.should_receive(:compare).and_return(true)
    
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
    it "should use sha256 by default" do
      SecureURI.hasher.should == SecureURI::SHA256Hasher
    end

    describe "class" do
      before(:all) do
        @original_hasher = SecureURI.hasher

        class HasherSub < SecureURI::Hasher
        end
      end

      after(:all) do
        # "Naughty naughty", said the Class to the spec
        # "Neccessary evil", replied the spec.
        SecureURI.__send__(:hasher=, @original_hasher)
      end

      it "should set hasher when subclassed" do
        SecureURI.hasher.should == HasherSub
      end

      it "should raise an error when hash method isn't overridden" do
        lambda {
          SecureURI::Hasher.hash "string"
        }.should raise_error("hash method needs to be overridden")
      end
      
      it "should raise an error when compare method isn't overridden" do
        lambda {
          SecureURI::Hasher.compare "string", "hash"
        }.should raise_error("hash method needs to be overridden")
      end
    end
  end
end
