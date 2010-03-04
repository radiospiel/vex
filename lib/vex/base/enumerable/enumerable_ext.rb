module Enumerable
  def any_not?(&block)
    not all? { |e| yield(e) }
  end
  
  def none?(&block)
    not any? { |e| yield(e) }
  end
  
  def stable_sort_by
    # NOTE: if soort_by wouldn't enumerate the array members from
    # the beginning this would fail.
    i=0
    sort_by { |x| [ yield(x), i+=1 ] } 
  end

  def hmap(&block)
    inject({}) { |hash, obj| hash[obj] = yield(obj); hash }
  end
end

module Enumerable::Etest
  def test_stable_sort_by
    data = [[1, 'b'], [1, 'c'], [0, 'b'], [0, 'a']]

    # This might or might not fail, but is not guaranteed to do so: 
    # assert_equal [[0, 'b'], [0, 'a'], [ 1, 'b'], [1, 'c']], data.stable_sort_by { |t| t[0] }
    assert_equal [[0, 'b'], [0, 'a'], [ 1, 'b'], [1, 'c']], data.stable_sort_by { |t| t[0] }
  end

  def test_any_none(&block)
    assert_equal(false, [ 1, 2, true, false ].any?(&:nil?))
    assert_equal(true, [ 1, 2, true, false ].none?(&:nil?))
    assert_equal(true, [ 1, 2, true, false, nil ].any?(&:nil?))
    assert_equal(false, [ 1, 2, true, false, nil ].none?(&:nil?))

    assert_equal(true, [ nil ].any?(&:nil?))
    assert_equal(false, [ 1 ].any?(&:nil?))
    assert_equal(false, [ ].any?(&:nil?))

    assert_equal(false, [ nil ].none?(&:nil?))
    assert_equal(true, [ 1 ].none?(&:nil?))
    assert_equal(true, [ ].none?(&:nil?))
  end

  def test_any_not_all(&block)
    assert_equal(true, [ 1, 2, true, false ].any_not?(&:nil?))
    assert_equal(true, [ 1, 2, nil ].any_not?(&:nil?))
    assert_equal(false, [ nil ].any_not?(&:nil?))
    assert_equal(true, [ 1 ].any_not?(&:nil?))
    assert_equal(false, [ ].any_not?(&:nil?))
  end

  def test_hmap
    h = %w(1 2 3)

    assert_equal({ "1" => 1, "2" => 4, "3" => 9}, h.hmap do |line| line.to_i * line.to_i end)
  end
end
