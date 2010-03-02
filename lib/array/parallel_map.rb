require "timeout"

#
# a simple (really really simple) map-in-parallel multithreaded mapper.
module Array::ParallelMap

  def self.timeout(opts, &block)
    return yield unless opts[:timeout]
    begin
      Timeout.timeout(opts[:timeout], &block)
    rescue Timeout::Error
    end
  end

  def peach_with_index(opts = {}, &block)
    return [] if empty?
    
    threads = []
    
    each_with_index do |data, index|
      threads << Thread.new {
        Array::ParallelMap.timeout(opts) { yield(data, index) }
      }
    end
    
    threads.each do |thread| thread.join end
    self
  end

  def peach(opts = {}, &block)
    peach_with_index(opts) do |data, index|
      yield(data)
    end
  end

  def pmap(opts = {}, &block)
    semaphore = Mutex.new
    
    results = []

    peach_with_index(opts) do |data, index|
      r = yield(data)
      semaphore.synchronize { results[index] = r } 
    end
  
    results
  end
end

Array.send :include, Array::ParallelMap

module Array::ParallelMap::Etest
  MAX = 1000

  def calculate(repeat, method)
    (1..repeat).to_a.send(method) do |p| 
      (1..MAX).inject(0) do |sum, i| 
        # STDERR.puts Thread.current.object_id if i % 10000 == 0
        sum + p * i 
      end 
    end
  end
  
  def calculate_serial(repeat)
    calculate(repeat, :map)
  end

  def calculate_parallel(repeat)
    calculate(repeat, :pmap)
  end
  
  def test_pmap
    serial = calculate_serial(4)
    parallel = calculate_parallel(4)
    assert_equal(serial, parallel)
  end

  def test_pmap_timeout
    r = [1, 2].pmap(:timeout => 0.1) do |p|
      sleep 0.2
      p * p
    end
    
    assert_equal([], r)
  end
end
