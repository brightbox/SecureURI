require "uri"

begin
  require "bcrypt"
rescue LoadError
  puts "You need to install the 'bcrypt' gem"
  exit(1)
end

module SecureURI

  @@salt = nil
  HASH_REGEX = /(?:&hash=([^&]+)$|hash=([^&]+)&?)/

  def self.salt= string
    @@salt = string
  end

  def secure?
    !hash_param.nil?
  end

  def valid?
    return false unless secure?
    hash_query == salted_query
  end

  def secure!
    # Clear it out if it's already got a hash
    self.query[HASH_REGEX] = "" if secure?
    # Make sure to URLEscape the hash
    hash = URI.escape(hash_query, Regexp.new("([^#{URI::PATTERN::UNRESERVED}]|\\.)"))
    # Update query
    self.query = "#{query}&hash=#{hash}"
    # And return the entire updated url
    to_s
  end

protected

  def hash_param
    return unless query
    return unless q = (query[HASH_REGEX, 1] || query[HASH_REGEX, 2])
    URI.unescape(q)
  end

  def salted_query
    @@salt.to_s + query.to_s
  end

  def hash_query
    warn("SecureURI doesn't have a salt set.") if !@@salt || @@salt.empty?
    BCrypt::Password.create(salted_query)
  end

end

URI::Generic.__send__(:include, SecureURI)
