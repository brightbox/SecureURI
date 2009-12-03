module SecureURI
  # Placeholder class to make sure a hashing class is set before
  # the class is used.
  # 
  # Required methods:
  # * self.hash
  # 
  # The salt mechanism is there as most hashing implementations will
  # need a shared secret.
  # 
  # Subclass this class to automagically set the hasher to your class.
  class Hasher
    class << self
      # Lets us set the salt
      attr_writer :salt
      # Lets us read the salt; defaulting to an empty string
      def salt
        @salt || ""
      end

      # Takes a string and hashes it
      # 
      # Returns String
      def hash str
        raise "hash method needs to be overridden"
      end

      # Takes a hash and a string. Hashes the string using self#hash and 
      # compares to the hash passed in.
      # 
      # Returns True or False
      def compare hash, str
        hash == self.hash(str)
      end

      # Convenience method so subclassing Hasher automatically
      # sets the new (sub)class as the Hasher class in SecureURI
      def inherited klass
        SecureURI.hasher = klass
      end
    end
  end
end
