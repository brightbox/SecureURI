require "digest/sha2"

module SecureURI
  class SHA256Hasher < Hasher
    def self.hash str
      Digest::SHA256.hexdigest(str)
    end

    def self.compare hash, str
      hash == Digest::SHA256.hexdigest(str)
    end
  end
end