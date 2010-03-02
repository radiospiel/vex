module Hash::Cross
  # 
  # { :a => [ 1, 2], :b => [ "bb", "cc"], :c => :cc }.cross =>
  #
  # [
  #	{ :a => 1, :b => "bb", :c => :cc },
  #	{ :a => 2, :b => "bb", :c => :cc },
  #	{ :a => 1, :b => "cc", :c => :cc },
  #	{ :a => 2, :b => "cc", :c => :cc }
  # ]
  #
  def cross(*keys)
    dup.send :do_cross, *keys
  end

  private
  
  def do_cross(*keys)
    keys = self.keys if keys.empty?
    keys = keys.select { |key| self[key].is_a?(Array) }

    crossing = self.extract! *keys
    
    array = [ self ]
    
    keys.each do |key|
      r = []

      values = crossing[key]
      array.each do |obj|
        values.each do |value|
          # Note: the following (instead of the obj.dup.update() results in a ~10% 
          # faster cross implementation 
          o = obj.dup   
          o[key] = value
          r << o
        end
      end
      array = r
    end

    array
  end
end

module Hash::Cross::Etest
  def assert_equal_sets(a, b)
    return assert_equal_sets(Set.new(a), b) unless a.is_a?(Set)
    return assert_equal_sets(a, Set.new(b)) unless b.is_a?(Set)
    
    assert_equal(a, b)
  end

  def test_cross_1    
    uncrossed = { :a => [ 1, 2], :b => [ "bb", "cc"], :c => :cc }
    uncrossed_orig = uncrossed.dup

    crossed = [
      { :a => [1, 2], :b => "bb", :c => :cc },
      { :a => [1, 2], :b => "cc", :c => :cc }
    ]

    assert_equal_sets(crossed, uncrossed.cross(:b))
    assert_equal(uncrossed_orig, uncrossed)
  end

  def test_cross_2
    uncrossed = { :a => [ 1, 2], :b => [ "bb", "cc"], :c => :cc }
    uncrossed_orig = uncrossed.dup

    crossed = [
        { :a => 1, :b => "bb", :c => :cc },
        { :a => 2, :b => "bb", :c => :cc },
        { :a => 1, :b => "cc", :c => :cc },
        { :a => 2, :b => "cc", :c => :cc }
      ]

    assert_equal_sets(crossed, uncrossed.cross)
    assert_equal(uncrossed_orig, uncrossed)
  end

  def test_cross_2_w_order
    uncrossed = { :a => [ 1, 2], :b => [ "bb", "cc"], :c => :cc }
    uncrossed_orig = uncrossed.dup

    crossed = [
        { :a => 1, :b => "bb", :c => :cc },
        { :a => 1, :b => "cc", :c => :cc },
        { :a => 2, :b => "bb", :c => :cc },
        { :a => 2, :b => "cc", :c => :cc }
      ]

    assert_equal(crossed, uncrossed.cross(:a, :b))
    assert_equal(uncrossed_orig, uncrossed)
  end

  def test_cross_simple
    uncrossed = { :a => :b }
    assert_equal([{:a=>:b}], uncrossed.cross)

    uncrossed = { :a => [ 1, :b ] }
    assert_equal([{:a=>1}, {:a=>:b}], uncrossed.cross)
  end

  def xtest_benchmark_1
    benchmark do
      5000.times do 
        uncrossed = { :a => [ 1, 2], :b => [ "bb", "cc"], :c => :cc }
        uncrossed.cross
      end
    end
  end
end
