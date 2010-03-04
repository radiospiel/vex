module Hash::Compact
  def compact
    dup.compact!
  end

  def compact!
    empty = []
    each { |k,v| empty << k if v.nil? }
    empty.each do |k| delete(k) end
    self
  end
end

class Hash
  include Compact
end

module Hash::Compact::Etest
  def test_compact_no
    h = { 1 => 2 }
    assert_equal(h.compact, h)
    assert_not_equal(h.compact.object_id, h.object_id)
    assert_equal(h.compact!.object_id, h.object_id)
    assert_equal(h.compact!, h.compact)
  end

  def test_compact
    h = { 1 => nil }
    assert_equal(h.compact, {})
    h.compact!
    assert_equal(h, {})
  end

  def test_compact_2
    h = { nil => 1 }
    assert_equal(h.compact, { nil => 1})
  end
end if VEX_TEST == "base"
