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
  module EasyAccess
    def method_missing(sym, *args, &block)
      return super if block_given?
      
      if args.length == 0 && sym.to_s =~ /^(.*)\?/
        !! EasyAccess.check(self, $1)
      elsif args.length == 0
        EasyAccess.fetch(self, sym)
      elsif args.length == 1 && sym.to_s =~ /^(.*)\=/
        v = args.first 
        v = v.dup if v.is_a?(Hash)
        EasyAccess.set(self, $1, v)
      else
        super
      end
    end

    def self.check_key(hash, key)
      key if hash.key?(key)
    end

    def self.check(hash, key)
      check_key(hash, key.to_s) || check_key(hash, key.to_sym)
    end
    
    def self.fetch(hash, key)
      if !(k = check(hash, key))
        raise NoMethodError, "undefined key `#{key}' for #{self.inspect}"
      end
      
      eazy_access hash.fetch(k)
    end

    def self.set(hash, key, value)
      k = check(hash, key) || key
      hash[k] = value
    end
    
    def self.eazy_access(obj)
      obj.eazy_access! if obj.is_a?(Hash)
      obj
    end
  end

  def eazy_access
    dup.eazy_access!
  end
  
  def eazy_access!
    # extend always returns self
    @eazy_accessible ||= extend(EasyAccess)
  end
  
  def eazy_accessible?
    @eazy_accessible
  end
end

module Hash::EasyAccess::Etest
  def test_eazy_access_hashes
    h = { :a => { "b" => "ccc" }}
    h1 = h.eazy_access!
    assert h.eazy_accessible?
    assert h1.eazy_accessible?
    
    assert_equal("ccc", h.a.b)
    assert h1.object_id == h.object_id

    assert h.a?
    assert !h.b?
    assert h.a.b?
    assert !h.a.c?
  end

  def test_eazy_access_hashes_2
    h = { :a => { "b" => "ccc" }}
    h1 = h.eazy_access
    assert !h.eazy_accessible?
    assert h1.eazy_accessible?
    
    assert_equal("ccc", h1.a.b)
    assert h1.object_id != h.object_id

    assert h1.a?
    assert !h1.b?
    assert h1.a.b?
    assert !h1.a.c?
  end

  def test_eazy_access_assigns
    h = { :a => { "b" => "ccc" }}
    h.eazy_access!
    
    h.a = 2
    
    assert_equal({ :a => 2}, h)
    
    h.b = 2
    assert_equal({ :a => 2, "b" => 2}, h)

    v = { :c => { :d => 2 } }
    assert !v.eazy_accessible?
    
    h.b = v
    assert_equal(2, h.b.c.d)
    assert !v.eazy_accessible?
    assert h.b.eazy_accessible?
  end
end
