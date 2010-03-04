class Hash
  def with_simple_access
    Deprecation.report "Hash#with_simple_access", "Hash#easy_access"
    easy_access!
  end
end

module Hash::SimpleAccessMethods; end

module Hash::SimpleAccessMethods::Etest
  def test_simple_access
    h = { :a => "aa", :b => "bb", "c" => "cc" }
    Deprecation.quiet do
      h.with_simple_access
    end
    
    assert_equal("aa", h.a)
    assert_equal("bb", h.b)
    assert_equal("cc", h.c)
  end

  def test_missing_methods
    h = { :a => "aa", :b => "bb", "c" => "cc" }
    Deprecation.quiet do
      h.with_simple_access
    end
    assert_raise(NoMethodError) {  h.x }
    assert_raise(NoMethodError) {  h.a(1) }
  end

  def test_assignments
    h = { :a => "aa", :b => "bb", "c" => "cc" }
    Deprecation.quiet do
      h.with_simple_access
    end
    
    h.a = 2
    assert_equal(2, h.a)
  end

  def test_respond_to
    h = { :a => "aa", :b => "bb", "c" => "cc" }
    Deprecation.quiet do
      h.with_simple_access
    end

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
    Deprecation.quiet do
      h.with_simple_access
    end

    assert_equal("bb", h.a.b)
  end
end if VEX_TEST == "base"
