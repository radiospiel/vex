module Hash::EnsureKeys
  def keys?(*keys)
    (keys - self.keys()).empty?
  end
end

class Hash
  include EnsureKeys
end

module Hash::EnsureKeys::Etest
  def test_ensure_keys
    h = { :a => "a" }
    assert_equal true, h.keys?(:a)
    assert_equal true, h.keys?
    assert_equal false, h.keys?(:a, :b)
  end
end if VEX_TEST == "base"
