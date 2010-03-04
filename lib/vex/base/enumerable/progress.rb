module Enumerable
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
  def test_with_progress
    Enumerable::ConsoleProgress.any_instance.stubs(:print_line).returns(nil)
    
    r = [ 1, 2 ].with_progress.map do |s| s * s end
    assert_equal( [ 1, 4], r)
  end
end if VEX_TEST == "base"
