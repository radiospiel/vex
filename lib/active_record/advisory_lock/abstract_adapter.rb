module ActiveRecord::ConnectionAdapters
  class AbstractAdapter
    def locked(lock, opts = {})
      raise ArgumentError, "Missing implementation #{self.class}#locked()"
    end
  end
end

module ActiveRecord::ConnectionAdapters::AbstractAdapter::Etest
  def test_abstract_adapter
    assert_raise(ArgumentError) {  
      ActiveRecord::ConnectionAdapters::AbstractAdapter.new.locked("lock")
    }
  end
end
