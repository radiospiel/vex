module ActiveRecord::Each
  #
  # Options:
  #
  #   :start (default: 0)
  #   :batch_size (default: 1000).
  #
  # and additional search options (:conditions, etc.pp.)
  #
  def each(opts={}, &block)
    find_in_batches(opts) do |batch| 
      batch.each(&block)
    end    
  end

  #
  # Step through and instantiate each member of the class and 
  # execute on it, but instantiate no more than :batch_size instances
  # at any given time.
  # 
  # Safe for destructive actions or actions that modify the fields 
  # your :order or :conditions clauses operate on.  
  def each_batch(options = {}, &block)
    find_in_batches(options, &block)
  end

  def with_progress(impl = :console)
    Enumerable::Progress::IMPLEMENTATIONS[impl].new(self, self.count)
  end
end

ActiveRecord::Base.extend ActiveRecord::Each
