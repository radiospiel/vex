require "md5"
require 'openssl'
require 'digest/sha1'

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
    :hash => "sha1",
    :secret => "46a348efe02807c999d69709abdbcd1b",
    :limit => 800,        # This should be safe for an URL
    :crypt => false
  }
  
  class Hashes < BlankSlate
    def md5(s)
      Digest::MD5.hexdigest s
      MD5.md5(s)
    end
    
    def sha1(s)
      Digest::SHA1.hexdigest s
    end
  end
  
  def self.hash!(opts, data)
    Hashes.new.__send__ opts[:hash], data
  end
  
  def self.aes(way, data, opts)
    return data if opts[:crypt] == false
    
    # get the password and make sure it is long enough for the algorith to work
    secret = opts[:crypt].is_a?(String) ? opts[:crypt] : opts[:secret]
    secret = Digest::SHA1.hexdigest(secret)
    
    c = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    c.send way
    c.key = secret
    s = c.update(data)
    s << c.final
  end
  
  def self.encode(s)
    Base64.encode64(s).gsub("\n", '').gsub("=", '-')
  end
  
  def self.decode(s)
    Base64.decode64(s.gsub("-", '='))
  end

  def self.limit!(s, opts)
    raise TokenTooLong, "Token too long: had #{s.length} bytes (allowed #{opts[:limit]})" if opts[:limit] && s.length > opts[:limit]
    s
  end
  
  public
  
  def self.generate(data, opts = {})
    opts = DEFAULTS.dup.update(opts)
    expires = opts[:expires] && opts[:expires].to_i
    
    data = data.to_json
    
    hash = hash!(opts, "#{opts[:secret]}-#{expires}:#{data}")
    s = "#{opts[:hash]}:#{hash}:#{expires}:#{data}"

    s = aes(:encrypt, s, opts)
    s = encode(s)
    limit!(s, opts)
  end
  
  def self.validate(s, opts = {})
    opts = DEFAULTS.dup.update(opts)

    begin
      s = decode(s)
      s = aes(:decrypt, s, opts)
    rescue SafeToken::CipherError
      raise InvalidToken, "Invalid token encryption: #{$!}"
    end

    raise InvalidToken, "Invalid token syntax" unless s =~ /^([^:]*):([^:]*):([^:]*):(.*)/

    method, hash, expires, data = $1, $2, $3, $4
    raise InvalidToken, "Invalid token #{s}" unless hash!(opts, "#{opts[:secret]}-#{expires}:#{data}") == hash
  
    if !expires.empty?
      expires = Time.at(expires.to_i)
      raise TokenExpired, expires if expires < Time.now      
    end
    
    r = ActiveSupport::JSON.decode(data)
    r.is_a?(Hash) ? r.with_indifferent_access : r
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
  
  def test_token_indifferent_access
    token = SafeToken.generate(data, :crypt => true)
    d1 = SafeToken.validate(token, :crypt => true)
    assert_equal(data["a"], d1[:a])
    assert_equal(data["a"], d1["a"])
  end
  
  def test_token_w_crypt
    token = SafeToken.generate(data, :crypt => true)
    assert_equal data, SafeToken.validate(token, :crypt => true)
  end
  
  def test_token_w_md5
    token = SafeToken.generate(data, :hash => :md5)
    assert_equal data, SafeToken.validate(token, :hash => :md5)
    assert_raise(SafeToken::InvalidToken) {  
      SafeToken.validate(token)
    }
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

