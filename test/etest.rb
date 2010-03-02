module Object::Etest
  class X
    attributes :a, :b

    def initialize(a,b)
      @a = a
      @b = b
    end
  end

  def test_attrs
    x=X.new("a", "b")
    assert_equal("a", x.a)
    assert_equal("b", x.b)
    assert_raise(NoMethodError) { x.a = 1 }
  end
end
