class Array
  def extract_options!
    if last.is_a?(Hash)
      pop
    else
      {}
    end
  end
end

module Array::Etest
  def test_extract_options
    arr = %w(1 2)
    assert_equal({}, arr.extract_options!)
    assert_equal(%w(1 2), arr)

    arr = [ 1, 2, { :a => :b }]
    assert_equal({ :a => :b }, arr.extract_options!)
    assert_equal( [ 1,  2 ], arr)
  end
end if VEX_TEST == "boot"

