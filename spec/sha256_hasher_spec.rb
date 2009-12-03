require File.dirname(__FILE__) + '/spec_helper'

include SecureURI

describe SHA256Hasher do
  it "should hash a string" do
    Digest::SHA256.should_receive(:hexdigest).with("this is my string").and_return("zomg hash!")
    hash = SHA256Hasher.hash("this is my string")

    hash.should_not be_nil
    hash.should be_a_kind_of(String)
    hash.should == "zomg hash!"
  end

  it "should use the salt when hashing a string" do
    Digest::SHA256.should_receive(:hexdigest).with("this is my stringmy salt").and_return("my hash")

    SHA256Hasher.salt = "my salt"
    SHA256Hasher.hash("this is my string").should == "my hash"
  end
end