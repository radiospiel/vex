module ActiveRecord::Resolver
  #
  # resolves an object.
  def resolve(obj)
    case obj
    when self   then obj
    when Fixnum then self.find(obj)
    when String then self.find(Integer(obj))
    when Array  then obj.map { |o| resolve(o) }
    else        raise InvalidArgument, obj
    end
  end

  #
  # resolves an object into an integer ID, possibly without DB lookup
  def resolve_id(obj)
    case obj
    when self then obj.id
    when Fixnum, Bignum then obj
    when String then Integer(obj)
    when Array  then obj.map { |o| resolve_id(o) }
    else        raise InvalidArgument, obj
    end
  end
end

ActiveRecord::Base.extend ActiveRecord::Resolver
