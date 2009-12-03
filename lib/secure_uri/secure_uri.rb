module SecureURI

  HASH_REGEX = /(?:&hash=([^&]+)$|hash=([^&]+)&?)/

  class << self
    def hasher
      if @hasher[/::/]
        arr = @hasher.split("::")
        klass = Kernel
        arr.each do |c|
          klass = klass.const_get(c)
        end
        klass
      else
        Kernel.const_get(@hasher)
      end
    end

    def hasher= class_name
      @hasher = class_name.to_s
    end
    protected :hasher=

    @hasher ||= "SecureURI::Hasher"
  end

  def secure?
    !hash_string.empty?
  end

  def valid?
    return false unless secure?
    SecureURI.hasher.compare hash_string, url_minus_hash
  end

  def secure!
    hash = URI.escape(url_hash, Regexp.new("([^#{URI::PATTERN::UNRESERVED}]|\\.)"))
    self.query = (self.query_minus_hash + "&hash=#{hash}")
    to_s
  end

protected

  def hash_string
    URI.unescape(query.to_s.scan(HASH_REGEX).flatten.compact.first.to_s)
  end

  def url_hash
    SecureURI.hasher.hash url_minus_hash
  end

  def url_minus_hash
    to_s.gsub(HASH_REGEX, "")
  end

  def query_minus_hash
    query.to_s.gsub(HASH_REGEX, "")
  end

end
