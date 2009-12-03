require "digest/sha2"

module SecureURI
  class SHA256Hasher < Hasher
    def self.hash str
      Digest::SHA256.hexdigest(str+salt)
    end
  end
end
