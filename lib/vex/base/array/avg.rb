module Array::Average
  def avg
    return 0 if empty?

    sum = inject(0) { |s, i| s + i }

    avg = sum / length
    return avg if length * avg == sum
    sum * 1.0 / length
  end
end

class Array
  include Average
end

module Array::Average::Etest
  def test_avg
    assert_equal(1, [ 1 ].avg)
    assert_equal(2, [ 1, 3 ].avg)
    assert_equal(0, [ ].avg)
  end
end if VEX_TEST == "base"
