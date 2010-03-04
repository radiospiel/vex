class Object
  module SingletonMethods
    # returns the singleton class of an object
    def singleton_class
      class << self; self; end
    end

    # defines a method on an object
    def define_object_method(name, &block)
      singleton_class.send :define_method, name, &block
    end
  end

  include SingletonMethods
end

module SingletonMethods::Etest
  def test_singleton_methods
    s = "s"
    s.define_object_method :bla do "blabla" end
    assert_equal("blabla", s.bla)
  end
end if VEX_TEST == "base"
