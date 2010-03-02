class ModelToken
end

__END__

class ModelToken < Hash
  def self.for(*args)
    opts = args.extract_options!
    raise ArgumentError, "Too many arguments" unless args.length < 2

    d = { :expires => Time.now + 24.hours }
    if model = args.first
      d.update :klass => model.class.name, :id => model.id 
    end
    d.update opts

    new SafeToken.generate(d)
  end

  def self.validate(token, opts = {})
    token = ModelToken.new(token)
    opts.each do |k,v|
      val = begin token.send(k) rescue NoMethodError end
      raise SafeToken::InvalidToken, "Missing validation #{k} => #{v.inspect} (is #{val.inspect})!" unless val == v
    end

    token
  end
  
  attr :token

  def model
    klass.constantize.find(self["id"])
  end
  
  def to_s
    @token ||= SafeToken.generate(self)
  end
  
  private
  
  def initialize(data)
    self.with_simple_access
    self.with_indifferent_access

    if data.is_a?(String)
      @token = data
      data = SafeToken.validate(data)
    end

    update(data)
  end

end

module ModelToken::Etest
  def test_creation 
    token = ModelToken.for(User.first).to_s
    assert_kind_of(String, token)
    assert_equal User.first, ModelToken.new(token).model
  end

  def test_extra_parameters 
    token = ModelToken.for(User.first, :access => "download").to_s
    assert_equal "download", ModelToken.new(token).access
  end

  def test_validation 
    token = ModelToken.for(User.first, :access => "download").to_s

    t = ModelToken.validate(token, :access => "download")
    assert_equal "download", t.access
    assert_equal User.first, ModelToken.new(token).model

    t = ModelToken.validate(token, "access" => "download")
    assert_equal "download", t.access
    assert_equal User.first, ModelToken.new(token).model
  end

  def test_validation_failed
    token = ModelToken.for(User.first, :access => "read").to_s
    assert_raise(SafeToken::InvalidToken) { ModelToken.validate(token, :access => "download") }
    assert_raise(SafeToken::InvalidToken) { ModelToken.validate(token, :access => "read", :really => true) }

    token = ModelToken.for(User.first, :access => nil).to_s
    assert_raise(SafeToken::InvalidToken) { ModelToken.validate(token, :access => "download") }

    token = ModelToken.for(User.first).to_s
    assert_raise(SafeToken::InvalidToken) { ModelToken.validate(token, :access => "download") }
  end

  def test_nil_tokens_validation
    token = ModelToken.for(:access => "read").to_s
    assert_raise(SafeToken::InvalidToken) { ModelToken.validate(token, :access => "download") }
    assert_raise(SafeToken::InvalidToken) { ModelToken.validate(token, :access => "read", :really => true) }

    token = ModelToken.for(User.first, :access => nil).to_s
    assert_raise(SafeToken::InvalidToken) { ModelToken.validate(token, :access => "download") }

    token = ModelToken.for(User.first).to_s
    assert_raise(SafeToken::InvalidToken) { ModelToken.validate(token, :access => "download") }
  end

  def test_nil_tokens
    token = ModelToken.for(:access => "read", :filename => "filename").to_s
    assert_raise(SafeToken::InvalidToken) { ModelToken.validate(token, :access => "download") }
    assert_raise(SafeToken::InvalidToken) { ModelToken.validate(token, :access => "read", :really => true) }

    t = ModelToken.validate(token, :access => "read")
    assert_equal("filename", t.filename)
  end
end
