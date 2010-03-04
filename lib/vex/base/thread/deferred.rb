class Thread
  def self.uid
    "#{$$}.#{Thread.current.object_id}"
  end
  
  def self.deferred(&block)
    new { 
      Thread.current.abort_on_exception = true
      
      begin
        yield
      rescue
        App.logger.warn "Caught exception in background processing: #{$!}"
      end
    }
  end
end

module Thread::Etest
  def test_deferred
    i = 0
    Thread.deferred do
      i = 1
    end
    
    Thread.sleep 0.05
    assert_equal(1, i)
  end

  def test_deferred_exception
    i = 0
    Thread.deferred do
      i = 1
      raise
      i = 2
    end
    
    Thread.sleep 0.05
    assert_equal(1, i)
  end

  def test_pids
    pids = [ Thread.uid ]
    
    Thread.deferred { pids[1] = Thread.uid }
    Thread.deferred { pids[2] = Thread.uid }
    
    Thread.sleep 0.05
    assert_equal(pids, pids.compact)
    assert_equal(pids, pids.uniq)
  end
end if VEX_TEST == "base"
