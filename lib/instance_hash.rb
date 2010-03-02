#
# Tests for InstanceHash object extension
#
module InstanceHash
end

module InstanceHash::Etest
  class X
    def initialize(a, b)
      @a, @b = a, b
    end
  end

  def test_t1
    assert_equal({}, Object.new.instance_variables_hash)
    assert_equal({ "@a" => :aa,  "@b" => :bb}, X.new(:aa, :bb).instance_variables_hash)
    assert_equal({ :a => :aa,  :b => :bb}, X.new(:aa, :bb).instance_variables_hash(:symbol_keys))
  end
end
