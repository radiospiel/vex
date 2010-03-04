class Hash
  def without(*keys)
    cpy = self.dup
    keys.each { |key| cpy.delete(key) }
    cpy
  end
end

#
# - allows to use hash.xx.yy where you would have to use
# hash["xx"][:yy] etc.
#
# - supports 
#
#   hash.xx?
#
# as a shortcut for hash.key?(:xx) || hash.key?("xx")
#
# - does not support assignment, though; i.e.
#
#   hash.yy = zz
#
# will raise a NoMethodError.
#
class Hash
  module Sloppiness
    def method_missing(sym, *args, &block)
      return super unless args.empty? && !block_given?
      
      if sym.to_s =~ /^(.*)\?/
        return key?($1.to_s) || key?($1.to_sym)
      end
      
      begin
        return Sloppiness.sloppy(fetch(sym.to_sym))
      rescue IndexError
      end

      begin
        return Sloppiness.sloppy(fetch(sym.to_s))
      rescue IndexError
      end

      raise NoMethodError, "undefined key `#{sym}' for #{self.inspect}"
    end
    
    def self.sloppy(obj)
      obj.sloppy! if obj.is_a?(Hash)
      obj
    end
  end

  def sloppy
    dup.sloppy!
  end
  
  def sloppy!
    extend(Sloppiness)
    self
  end
end

module Hash::Sloppiness::Etest
  def test_sloppy_hashes
    h = { :a => { "b" => "ccc" }}
    h1 = h.sloppy!
    
    assert_equal("ccc", h.a.b)
    assert h1.object_id == h.object_id

    assert h.a?
    assert !h.b?
    assert h.a.b?
    assert !h.a.c?
  end

  def test_sloppy_hashes_2
    h = { :a => { "b" => "ccc" }}
    h1 = h.sloppy
    assert_equal("ccc", h1.a.b)
    assert h1.object_id != h.object_id

    assert h1.a?
    assert !h1.b?
    assert h1.a.b?
    assert !h1.a.c?
  end
end
