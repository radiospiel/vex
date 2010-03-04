class Range
  def limit(value)
    if value < first then first
    elsif value > last then last
    else value
    end
  end
end

class Numeric
  def limit(range)
    range.limit(self)
  end
end

module Range::Etest
  def test_range
    assert_equal 1, (1..3).limit(-1)
    assert_equal 1, (1..3).limit(1)
    assert_equal 2, (1..3).limit(2)
    assert_equal 3, (1..3).limit(3)
    assert_equal 3, (1..3).limit(4)
  end

  def test_numeric
    assert_equal 1, -1.limit(1..3)
  end
end if VEX_TEST == "base"