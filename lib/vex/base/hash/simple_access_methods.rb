module Hash::SimpleAccessMethods
  module AutoCreate
    def simple_access_reader_key(sym)
      super(sym) || begin
        self[sym] = nil
        sym
      end
    end
  end

  private
  
  def simple_access_reader_key(sym)
    sym = sym.to_sym
    return sym if key?(sym)
    sym = sym.to_s
    return sym if key?(sym)
    return nil
  end

  def simple_access_writer_key(sym)
    return nil unless sym.to_s =~ /^(.*)=$/
    simple_access_reader_key($1)
  end

  def method_missing(sym, *args, &block)
    return super if block_given?

    case args.length
    when 0
      if key = simple_access_reader_key(sym)
        r = self[key]
        r.with_simple_access if r.respond_to?(:with_simple_access)

        return r
      end

      raise ArgumentError, "Wrong number of arguments" if simple_access_writer_key(sym)
    when 1
      if key = simple_access_writer_key(sym)
        return self[key]=args.first
      end

      raise ArgumentError, "Wrong number of arguments" if simple_access_reader_key(sym)
    end

    super
  end
  
  public
  
  def respond_to?(sym)
    return true if simple_access_reader_key(sym)
    return true if simple_access_writer_key(sym)
    super
  end
end

class Hash
  def with_simple_access
    extend SimpleAccessMethods
  end
end

module Hash::SimpleAccessMethods::Etest
  def test_simple_access
    h = { :a => "aa", :b => "bb", "c" => "cc" }
    h.with_simple_access
    
    assert_equal("aa", h.a)
    assert_equal("bb", h.b)
    assert_equal("cc", h.c)
  end

  def test_missing_methods
    h = { :a => "aa", :b => "bb", "c" => "cc" }
    h.with_simple_access
    assert_raise(NoMethodError) {  h.x }
    assert_raise(ArgumentError) {  h.a(1) }
  end

  def test_assignments
    h = { :a => "aa", :b => "bb", "c" => "cc" }
    h.with_simple_access

#    assert_raise(NoMethodError) {  h.x = 1 }
    
    h.a = 2
    assert_equal(2, h.a)
  end

  def test_respond_to
    h = { :a => "aa", :b => "bb", "c" => "cc" }
    h.with_simple_access

    assert(h.respond_to?(:a))
    assert(h.respond_to?(:b))
    assert(h.respond_to?(:c))
    assert(h.respond_to?(:"a="))

    assert(h.respond_to?("a="))
    assert(h.respond_to?("a"))

    assert(h.respond_to?("c="))
    assert(h.respond_to?("c"))

    # inherited methods
    assert(h.respond_to?("keys"))

    # inherited methods
    assert(!h.respond_to?("unknown_key"))
    assert(!h.respond_to?("unknown_key="))
  end

  def test_simple_access_deep
    h = { :a => { :b => "bb" } }
    h.with_simple_access

    assert_equal("bb", h.a.b)
  end

  def test_simple_access_deep
    h = { :a => { :b => "bb" } }
    h.with_simple_access

    assert_equal("bb", h.a.b)
  end

end
