require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SecureURI" do

  before do
    @url = "http://example.com/path?query=string"
    @uri = URI.parse(@url)

    @secure_url = "http://example.com/path?query=string&hash=ZOMG-HASH"
    @secure_uri = URI.parse(@secure_url)

  end

  it "should be a URI" do
    @uri.should be_a_kind_of(URI)
  end

  it "should turn into a secure url" do
    @uri.should_receive(:hash_query).and_return("ZOMG-HASH")
    @uri.secure!
    @uri.query.should =~ /hash=ZOMG-HASH/
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
    @secure_uri.should_receive(:hash_query).and_return(hash_obj)
    @secure_uri.should be_valid
  end

  it "should fail validation as a secure url" do
    @secure_uri.should_receive(:hash_query).and_return("NOT_HASH")
    @secure_uri.should_not be_valid
  end

  it "should update the hash if the query changes" do
    @secure_uri.query += "&foo=bar"
    @secure_uri.query.should =~ /foo=bar/
    @secure_uri.query.should =~ /hash=ZOMG-HASH/

    @secure_uri.should_receive(:hash_query).and_return("new-hash")
    @secure_uri.secure!

    @secure_uri.query.should =~ /hash=new-hash/
    @secure_uri.query.should_not =~ /hash=ZOMG-HASH/
  end

  describe "hash_query" do

    it "should warn if a salt isn't set" do
      pending "how do you test a warn()?"
      self.should_receive(:warn).with("SecureURI doesn't have a salt set.").and_return(nil)
      
      @uri.__send__(:hash_query)
    end

    describe "with salt" do
      before do
        # Set our salt
        SecureURI.salt = "my lovely salt"
      end

      it "should hash a query" do
        BCrypt::Password.should_receive(:create).with("my lovely saltquery=string").and_return("the hash")

        hash = @uri.__send__(:hash_query)

        hash.should == "the hash"
      end
    end
  end
end
