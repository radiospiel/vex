module Enumerable
  # gives the behaviour of Ruby 1.9's Enumerable#group_by, as opposed to ActiveSupport::Enumerable#group_by
  def grouped_by(&block)
    inject({}) { |hash, obj| (hash[yield(obj)] ||= []) << obj; hash }    
  end
  
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
  
  class Progress
    def initialize(base, count=nil)
      @base = base
      @idx = 0
      @count = count
      @count ||= base.is_a?(Range) ? (base.max - base.min + 1) : length
    end

    def method_missing(sym, *args)
      return @base.send(sym, *args) unless block_given?

      r = @base.send sym, *args do |*args|
        begin
          yield *args
        ensure
          @idx += 1
          on_progress(@idx, @count)
        end
      end
    end
  end
  
  class ConsoleProgress < Progress
    def initialize(base, count=nil)
      @start, @last = Time.now, nil
      super
    end
    
    private
    
    def print_line(s)
      print s
    end
    
    def on_progress(idx, count)
      if idx == count
        print_line("\r#{"%.1f%%" % 100}#{" " * 40}\n") 
        return 
      end
      
      now = Time.now
      return if @last && now - @last <= 1
      
      @last = now
      span = @last - @start
      remaining = ((count * 1.0 / idx) - 1) * span

      print_line "\r#{"%.1f%%" % ((100.0 * idx) / count)}\t#{"   %.1f secs remaining            " % remaining}"
    end
  end

  class Progress
    IMPLEMENTATIONS = {
      :console => ConsoleProgress
    }
  end
  
  def with_progress(impl = :console)
    Progress::IMPLEMENTATIONS[impl].new(self)
  end
end

module Enumerable::Etest
  def test_stable_sort_by
    data = [[1, 'b'], [1, 'c'], [0, 'b'], [0, 'a']]

    # This might or might not fail, but is not guaranteed to do so: 
    # assert_equal [[0, 'b'], [0, 'a'], [ 1, 'b'], [1, 'c']], data.stable_sort_by { |t| t[0] }
    assert_equal [[0, 'b'], [0, 'a'], [ 1, 'b'], [1, 'c']], data.stable_sort_by { |t| t[0] }
  end

  def test_grouped_by
    assert_equal({ 0 => [ 0, 2, 4], 1 => [ 1, 3, 5 ]}, (0..5).grouped_by { |i| i % 2 })
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

  def test_with_progress
    Enumerable::ConsoleProgress.any_instance.stubs(:print_line).returns(nil)
    
    r = [ 1, 2 ].with_progress.map do |s| s * s end
    assert_equal( [ 1, 4], r)
  end

end
