require "uri"

begin
  require "rubygems"
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
    !hash_string.nil?
  end

  def valid?
    return false unless secure?
    mah_hash = BCrypt::Password.new(hash_string) rescue nil
    mah_hash == salt + url_minus_hash
  end

  def secure!
    hash = URI.escape(url_hash, Regexp.new("([^#{URI::PATTERN::UNRESERVED}]|\\.)"))
    self.query = (self.query_minus_hash + "&hash=#{hash}")
    to_s
  end

protected

  def salt
    warn("SecureURI.salt not set") unless @@salt
    @@salt.to_s
  end

  def hash_string
    URI.unescape(query.to_s.scan(HASH_REGEX).flatten.compact.first.to_s)
  end

  def url_hash
    BCrypt::Password.create(salt + url_minus_hash)
  end

  def url_minus_hash
    to_s.gsub(HASH_REGEX, "")
  end

  def query_minus_hash
    query.to_s.gsub(HASH_REGEX, "")
  end

end

URI::Generic.__send__(:include, SecureURI)