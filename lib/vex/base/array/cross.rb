module Array::Cross
  def cross(other, &block)
    if !block_given?
      r = []
      cross(other) do |mine, others|
        r << [ mine, others ]
      end
      return r 
    else    
      each do |obj|
        other.each do |oo| yield obj, oo end
      end
    end
  end
end

Array.send :include, Array::Cross

module Array::Cross::Etest
  def test_cross
    assert_equal( [[1,1]],                            [1].cross([1])  )
    assert_equal( [[1,1], [2,1]],                     [1, 2].cross([1])  )
    assert_equal( [[1,1], [1,3], [2,1], [2,3]],       [1, 2].cross([1, 3])  )
    assert_equal( [],                                 [1, 2].cross([])  )
  end
end
