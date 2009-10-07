module SecureURI
  class Hasher
    def self.hash str
      raise "#{self} needs to override Hasher#hash"
    end
    
    def self.compare str
      raise "#{self} needs to override Hasher#compare"
    end

    def self.inherited klass
      SecureURI.hasher = klass.to_s
    end
  end
end