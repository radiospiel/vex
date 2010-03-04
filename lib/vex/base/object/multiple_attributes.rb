class Module
  module MultipleAttributes
    def attributes(*args)
      writable_flag = args.last
      if writable_flag != true && writable_flag != false
        writable_flag = false
      else
        args.pop
      end

      args.each do |arg|
        attr arg, writable_flag
      end
    end
  end

  include MultipleAttributes
end

module Module::MultipleAttributes::Etest
  class X
    attributes :a
    attributes :b, :c

    attributes :d, :e, true
  
    def initialize
      @a = "a"
      @b = "b"
      @c = "c"
      @d = "d"
      @e = "e"
    end
  end
  
  def test_ma
    x = X.new
    assert_equal %w(a b c d e), [ x.a, x.b, x.c, x.d, x.e ]

    assert_raise(NoMethodError) {
      x.a = 1
    }

    assert_raise(NoMethodError) {
      x.b = 1
    }

    assert_raise(NoMethodError) {
      x.c = 1
    }

    x.d = 1
    x.e = 2
    
    assert_equal 1, x.d
    assert_equal 2, x.e
  end
end
