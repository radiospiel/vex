require 'digest/sha1'
require 'json'
require 'base64'

module SafeToken
  CipherError = if defined?(OpenSSL::Cipher::CipherError)
    OpenSSL::Cipher::CipherError
  else
    OpenSSL::CipherError
  end
  
  class InvalidToken < RuntimeError; end
  class TokenTooLong < InvalidToken; end
  class TokenExpired < InvalidToken 
    attr :expires
    def initialize(expires)
      @expires = expires
    end
    
    def to_s
      "token expired at #{expires}"
    end
  end
  private
  
  DEFAULTS = {
    :secret => "46a348efe02807c999d69709abdbcd1b",
    :limit => 800,        # This should be safe for an URL
    :crypt => false
  }
  
  def self.hash!(opts, data)
    Digest::SHA1.hexdigest data
  end
  
  def self.aes(encrypt_or_decrypt, data, opts)
    return data if opts[:crypt] == false
    
    # get the password and make sure it is long enough for the algorithm to work
    secret = opts[:crypt].is_a?(String) ? opts[:crypt] : opts[:secret]
    secret = Digest::SHA1.hexdigest(secret)
    
    c = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    c.send encrypt_or_decrypt
    c.key = secret
    s = c.update(data)
    s << c.final
  end
  
  def self.encode64(s)
    Base64.encode64(s).gsub("\n", '').gsub("=", '-')
  end
  
  def self.decode64(s)
    Base64.decode64(s.gsub("-", '='))
  end

  def self.limit!(s, opts)
    if opts[:limit] && s.length > opts[:limit]
      raise TokenTooLong, "Token too long: (#{s.length} bytes, allowed are #{opts[:limit]})" 
    end
    s
  end
  
  public
  
  def self.generate(data, opts = {})
    opts = DEFAULTS.dup.update(opts)
    expires = opts[:expires].to_i if opts[:expires]
    
    data = data.to_json
    
    hash = hash!(opts, "#{opts[:secret]}-#{expires}:#{data}")
    s = "sha1:#{hash}:#{expires}:#{data}"

    s = aes(:encrypt, s, opts)
    s = encode64(s)
    limit!(s, opts)
  end
  
  def self.validate(s, opts = {})
    opts = DEFAULTS.dup.update(opts)

    begin
      s = decode64(s)
      s = aes(:decrypt, s, opts)
    rescue SafeToken::CipherError
      raise InvalidToken, "Invalid token encryption: #{$!}"
    end

    raise InvalidToken, "Invalid token syntax" unless s =~ /^([^:]*):([^:]*):([^:]*):(.*)/

    method, hash, expires, data = $1, $2, $3, $4

    unless hash!(opts, "#{opts[:secret]}-#{expires}:#{data}") == hash
      raise InvalidToken, "Invalid token #{s}"
    end
    
    if !expires.empty?
      expires = Time.at(expires.to_i)
      raise TokenExpired, expires if expires < Time.now      
    end
    
    JSON.parse(data)
  end
end

module SafeToken::Etest
  def data
    {"a" => "123232", "b" => { "c" => [ 1, 2, "d" ]}}
  end
  
  def test_expiration
    token = SafeToken.generate(data, :crypt => false, :expires => Time.now-10)
    assert_raise(SafeToken::TokenExpired) {  
      begin
        SafeToken.validate(token)
      rescue
        assert $!.to_s =~ /expired/
        raise
      end
    }

    token = SafeToken.generate(data, :crypt => false, :expires => Time.now+10)
    assert_equal data, SafeToken.validate(token)
  end
  
  def test_token
    token = SafeToken.generate(data, :crypt => false)
    assert_equal data, SafeToken.validate(token)
  end
  
  def test_token_w_crypt
    token = SafeToken.generate(data, :crypt => true)
    assert_equal data, SafeToken.validate(token, :crypt => true)
  end
  
  def test_token_w_crypt2
    token1 = SafeToken.generate(data, :crypt => "secret")
    token2 = SafeToken.generate(data, :crypt => true)
    token3 = SafeToken.generate(data, :crypt => false)
    assert_not_equal(token1, token2)
    assert_not_equal(token1, token3)
    assert_not_equal(token2, token3)
  end

  def test_invalid_enc_parameters
    token = SafeToken.generate(data, :crypt => true)

    OpenSSL::Cipher::Cipher.any_instance.stubs(:update).raises(SafeToken::CipherError)
    assert_raise(SafeToken::InvalidToken) {  
       assert_equal data, SafeToken.validate(token, :crypt => true)
    }
  end
end

