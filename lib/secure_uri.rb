require "uri"
%w(secure_uri hasher sha256_hasher).each do |file|
  require File.join(File.dirname(__FILE__), "secure_uri", file)
end

# All specific classes of URI are subclasses of Generic
URI::Generic.__send__(:include, SecureURI)