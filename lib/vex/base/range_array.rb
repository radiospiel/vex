class RangeArray < Array
  def initialize(array)
    min = max = nil

    array.each do |i|
      if min 
        if    i >= min && i <= max then next
        elsif i == min-1 then min = i
        elsif i == max+1 then max = i
        else
          push min, max
          min = max = i
        end
      else
        min = max = i
      end
    end
    
    push min, max if min
  end

  def push(min, max)
    super min == max ? min : min..max
  end
end

module RangeArray::Etest
  def ra(*array)
    RangeArray.new array
  end

  def test_range_array
    assert_equal [1..3],                        ra(1, 2, 3)
    assert_equal [1..3, 5..6],                  ra(1, 2, 3, 5, 6)
    assert_equal [1..3, 5..6, 8],               ra(1, 2, 3, 5, 6, 8)
    assert_equal [1..2, 7, 3, 5..6, 8],         ra(1, 2, 7, 3, 5, 6, 8)
    assert_equal [1..2, 7, 3, 5..6, 8, 4],      ra(1, 2, 7, 3, 5, 6, 8, 4)
    assert_equal [1..2, 7, 3, 5..6, 8, 4, -3],  ra(1, 2, 7, 3, 5, 6, 8, 4, -3)
  end
end if VEX_TEST == "base"
