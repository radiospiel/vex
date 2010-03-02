module Hash::EnsureKeys
  def ensure_keys!(*keys)
    missing = keys - self.keys()
    return if missing.empty?
    raise ArgumentError, "Missing keys #{missing.inspect}"
  end
end

module Hash::EnsureKeys::Etest
  def test_ensure_keys
    h = { :a => "a" }
    assert_raise(ArgumentError) { h.ensure_keys! :a, :b }
    assert_nothing_raised { h.ensure_keys! :a }
    assert_nothing_raised { h.ensure_keys! }    
  end
end
