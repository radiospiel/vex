class Rules::AddressMatcher; end

__END__

class Rules::AddressMatcher < Regexp
  attr :weight
  attr :address

  def to_s
    address
  end
  
  def ==(other)
    address == other.address
  end
  
  def initialize(address)
    parts = address.gsub(/^\s+/, "").gsub(/\s+$/, "").split(/\s+/)
    
    @address = parts.join(" ")
    @weight = parts.length
    
    rex = parts.map { |part| 
      case part
      when /^\:(.*)$/   then ":#{Regexp.escape $1}"
      when /^\.(.*)$/   then "\\.#{Regexp.escape $1}#\\w*"
      when /^#(.*)$/    then "\\.\\w+##{Regexp.escape $1}"
      when /^\/(.*)\/$/ then "\\.\\w+##{$1}"
      else                   raise Rules::InvalidRule, "Invalid address part #{part.inspect}"
      end
    }
    
    super(rex.join("\\s(\\S+\\s)*") + "$")
  end
  
  # an address matches if all entries in the address matcher are also in address,
  # in exactly that order.
  #
  # Note: the address must be compiled into a matching string via compile_address
  def match?(address)
    !!match(address)
  end
  
  def self.compile_address(address)
    return address if address.is_a?(String)
    
    address.map { |k,v| 
      k.is_a?(Symbol) ? ":#{k}" : ".#{k}##{v}"
    }.join(" ")
  end
end

__END__

module Rules::AddressMatcher::Etest
  def matcher(rule)
    Rules::AddressMatcher.new(rule)
  end
  
  def match?(req, rule, *args)
    scopes = []
    
    while args.length > 1
      scopes << [ args.shift, nil ]
    end

    raise("Invalid parameter") unless args.length == 1
    
    address = scopes + args.first.split(/\s+/).map do |p|
      raise("Invalid address") unless p =~ /^([.#])(.*)$/
      $1 == "." ? [ $2, nil ] : [ nil, $2 ]
    end
    
    if req == matcher(rule).match?(address)
      assert true
    else
      addr = scopes.map { |s| ":#{s}" }.join(" ") + " #{args[-1]}"
      assert false, "#{rule.inspect} should #{req ? "" : "not "}match #{addr.inspect}"
    end
  end

  def assert_match(*args)
    match?(true, *args)
  end

  def assert_nomatch(*args)
    match?(false, *args)
  end
  
  def test_no_scope
    assert_match    ".x",         ".x"
    assert_nomatch  ".x",         ".x .z"
    assert_match    ".x .z",      ".x .z"
    assert_match    ".x .z",      ".x .aaa .z"
    assert_match    ".x .aaa .z", ".x .aaa .z"
    assert_nomatch  ".x .bbb .z", ".x .aaa .z"
    assert_nomatch  ".x .y",      ".x .z"
    assert_match    ".z",         ".x .z"
    assert_nomatch  ".x .z",      ".z"
  end

  def test_scope
    assert_match    ".x",         :a, ".x"
    assert_match    ":a .x",      :a, ".x"
    assert_nomatch  ":a :b .x",   :a, ".x"
    assert_nomatch  ":a :b .x",   ".x"
    assert_nomatch  ":a :b .x",   :a, ".x"
    assert_nomatch  ":a :b .x",   :b, ".x"
    assert_match    ":a :b .x",   :a, :b, ".x"
    assert_match    ":a :b .x",   :a, :b, ".x"
  end

  def test_matcher
    assert_equal 3, matcher(":a :b .x").weight
  end
end
