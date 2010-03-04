class String
  def starts_with?(other)
    return false if other.length > length

    self[0, other.length] == other
  end

  def ends_with?(other)
    return false if other.length > length

    self[self.length-other.length..-1] == other
  end

  def constantize
    names = self.split('::')
    raise ArgumentError, "Cannot be blank" if blank?
    
    names.shift if names.first.empty?

    names.inject(Object) do |constant, name|
      constant.const_get(name) || constant.const_missing(name)
    end
  end
end

module String::Etest
  def test_starts_with
    assert "abcde".starts_with?("")
    assert "abcde".starts_with?("a")
    assert "abcde".starts_with?("ab")
    assert "abcde".starts_with?("abc")
    assert "abcde".starts_with?("abcd")
    assert "abcde".starts_with?("abcde")

    assert !("abcde".starts_with?("abcdef"))
    assert !("abcde".starts_with?("xy"))
  end

  def test_ends_with
    assert "abcde".ends_with?("")
    assert "abcde".ends_with?("e")
    assert "abcde".ends_with?("de")
    assert "abcde".ends_with?("cde")
    assert "abcde".ends_with?("bcde")
    assert "abcde".ends_with?("abcde")

    assert !("abcde".ends_with?("abcdef"))
    assert !("abcde".ends_with?("xy"))
  end

  def test_constantize
    assert_equal String, "String".constantize
    assert_raise(NameError) {
      "I::Dont::Know::This".constantize
    }
    assert_raise(ArgumentError) {
      "".constantize
    }
  end
end if VEX_TEST == "boot"
