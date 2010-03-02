module Array::EachBatch
  def each_batch(batch_size = 1000, &block)
    raise "Invalid parameter #{batch_size.inspect}, must be a Fixnum" unless batch_size.is_a?(Fixnum)

    data = dup
    begin
      batch = data.slice!(0..(batch_size-1))
      yield batch
    end until data.empty?
    self
  end
end

Array.send :include, Array::EachBatch

module Array::Cross::Etest
  def test_each_batch
    r = []
    [1,2,3,4,5,6,7,8,9].each_batch 3 do |batch|
      r << batch
    end 
    
    assert_equal( [[1,2,3],[4,5,6],[7,8,9]], r)

    r = []
    [1,2,3,4,5,6,7].each_batch 3 do |batch|
      r << batch
    end 
    
    assert_equal( [[1,2,3],[4,5,6],[7]], r)
  end
end
