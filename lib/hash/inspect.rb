
class Hash
  def inspect
    "{" + map { |k,v| "#{k.inspect} => #{v.inspect}" }.sort.join(", ") + "}"
  end
end
