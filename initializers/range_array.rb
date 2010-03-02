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


__END__

def RangeArray(array)
  RangeArray.new array
end

?> RangeArray [ 1, 2, 3]
=> [1..3]
>> RangeArray [ 1, 2, 3, 5, 6]
=> [1..3, 5..6]
>> RangeArray [ 1, 2, 3, 5, 6, 8]
=> [1..3, 5..6, 8]
>> RangeArray [ 1, 2, 7, 3, 5, 6, 8]
=> [1..2, 7, 3, 5..6, 8]
>> RangeArray [ 1, 2, 7, 3, 5, 6, 8, 4]
=> [1..2, 7, 3, 5..6, 8, 4]
>> RangeArray [ 1, 2, 7, 3, 5, 6, 8, 4, -3]
=> [1..2, 7, 3, 5..6, 8, 4, -3]
