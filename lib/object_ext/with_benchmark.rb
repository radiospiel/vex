module ObjectExt::WithBenchmark
  # a logger for WithBenchmark
  class Logger < ActiveSupport::BufferedLogger
    def initialize
      super(file = "#{RAILS_ROOT}/log/benchmark.log")
      warn "" unless File.exists?(file)
    end

    def warn(msg)
      super "#{Time.now.strftime("[%Y-%m-%d %H:%M:%S]")}: #{msg}"
    end
  end

  class BenchmarkProxy < BlankSlate
    def initialize(host, *args)
      @host = host

      if args.length == 1 && args.first.is_a?(String)
        @out, @label = nil, args.first
      else 
        @out, @label = *args
      end
    end

    def self.logger
      @logger ||= Logger.new
    end
    
    private
    
    def report(msg)
      if !@out
        logger = @host.respond_to?(:logger) && @host.logger || RAILS_DEFAULT_LOGGER

        logger.warn(msg)
        BenchmarkProxy.logger.warn(msg)
        STDERR.puts(msg) if RAILS_ENV == "development" && !EmbeddedTest.running?
      elsif @out.respond_to?(:warn)
        @out.warn(msg)
      elsif @out.respond_to?(:<<)
        @out << "#{msg}\n"
      end
    end
    
    def method_missing(*args, &block)
      result = ex = nil

      realtime = Benchmark.realtime do
        begin
          result = @host.__send__(*args, &block)
        rescue
          ex = $!
        end
      end

      msg = "#{@label || "benchmarked"}: #{ex && "EXCEPTION #{ex} after "}#{"%.2f secs" % realtime}"

      report(msg)

      raise ex if ex
      result
    end
  end

  def no_benchmark(*args, &block)
    block_given? ? yield : self
  end
  
  def benchmark(*args, &block)
    count = args.last.is_a?(Fixnum) ? args.pop : 1

    proxy = BenchmarkProxy.new self, *args, &block
    return proxy unless block_given?
    return proxy.yield(&block) if count <= 1
    return proxy.yield do 
      count.times(&block)
    end
  end

  def yield(&block); yield; end
end

module ObjectExt::WithBenchmark::Etest
  def test_results
    RAILS_DEFAULT_LOGGER.stubs(:warn).returns(nil)

    assert_equal 6, "string".benchmark.length
    assert_raise(NoMethodError) { 
      "string".benchmark.you_dont_know_me 
    }
  end

  def test_benchmark
    s = ""
    assert_equal 6, "string".benchmark(s, "").length
    assert s.length > 0
  end

  def test_label
    RAILS_DEFAULT_LOGGER.stubs(:warn).returns(nil)

    assert_equal 6, "string".benchmark("oh! a label!").length
  end

  class DL
    attr :msg
    def warn(s); 
      @msg = s
    end
  end
  
  def test_logger
    s = "string"

    def s.logger; @logger ||= DL.new; end
    assert s.respond_to?(:logger)
    assert s.logger.msg.blank?

    assert_equal 6, s.benchmark.length
    assert !s.logger.msg.blank?
  end
end
