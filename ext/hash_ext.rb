class Hash
  include Extras, Extract

  def with_simple_access
    extend Hash::SimpleAccessMethods
    self
  end

  def inspect
    "{" + map { |k,v| "#{k.inspect} => #{v.inspect}" }.sort.join(", ") + "}"
  end
end
