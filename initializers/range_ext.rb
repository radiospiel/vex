class Range
  def limit(value)
    if value < first then first
    elsif value > last then last
    else value
    end
  end
end

class Numeric
  def limit(range)
    range.limit(self)
  end
end
