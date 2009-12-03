require File.dirname(__FILE__) + '/spec_helper'

include SecureURI

describe Hasher do
  it "should have an empty salt by default" do
    Hasher.salt.should == ""
  end

  it "should accept a salt" do
    Hasher.should respond_to(:salt=)

    Hasher.salt = "my salt"
    Hasher.salt.should == "my salt"
  end

  it "should raise when hash is called" do
    lambda {
      Hasher.hash("my string")
    }.should raise_error("hash method needs to be overridden")
  end

  it "should use the hash method when comparing" do
    Hasher.should_receive(:hash).with("my string").and_return("my hash")

    Hasher.compare("my hash", "my string").should be_true
  end
end
