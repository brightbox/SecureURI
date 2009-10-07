begin
  require "rubygems"
  require "bcrypt"
rescue LoadError
  puts "You need to install the 'bcrypt' gem"
  exit(1)
end

module SecureURI
  class BCryptHasher < Hasher
    def self.hash str
      BCrypt::Password.create(str).to_s
    end

    def self.compare hash, str
      hash_obj = BCrypt::Password.new(hash) rescue nil
      hash_obj == str
    end
  end
end