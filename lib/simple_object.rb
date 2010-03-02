class SimpleObject < Hash
  def initialize(opts = {})
    update opts
    with_simple_access
  end
end

module SimpleObject::Etest
  def test_t1
    fake = SimpleObject.new :a => "aa"
    assert_equal("aa", fake.a)
  end
end
