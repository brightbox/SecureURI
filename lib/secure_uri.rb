require "uri"
%w(hasher secure_uri bcrypt_hasher).each do |file|
  require File.join(File.dirname(__FILE__), "secure_uri", file)
end

URI::Generic.__send__(:include, SecureURI)