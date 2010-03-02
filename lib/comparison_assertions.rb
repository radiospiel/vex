module ComparisonAssertions
  def assert_lt(p1, p2)
    assert(p1 < p2, "#{p1.inspect} should be less than #{p2.inspect} but is not")
  end

  def assert_le(p1, p2)
    assert(p1 <= p2, "#{p1.inspect} should be less than or equal #{p2.inspect} but is not")
  end

  def assert_ge(p1, p2)
    assert(p1 >= p2, "#{p1.inspect} should be greater than or equal #{p2.inspect} but is not")
  end

  def assert_gt(p1, p2)
    assert(p1 > p2, "#{p1.inspect} should be greater than #{p2.inspect} but is not")
  end

  # for reasons of API completeness and orthogonality only.

  def assert_eq(p1, p2)
    assert_equal(p1, p2)
  end

  def assert_ne(p1, p2)
    assert_not_equal(p1, p2)
  end
end

module ComparisonAssertions::Etest
  include ComparisonAssertions
  
  # I don't know how to test asserts. This, at least, give (fake) C0 coverage
  def test_comparision_assertions
    assert_lt 1, 2
    assert_le 1, 1
    assert_ge 2, 2
    assert_gt 2, 1
    assert_eq 2, 2
    assert_ne 1, 2
  end
end
