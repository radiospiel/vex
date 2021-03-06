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
  module Slop
    private
    
    def lookup_sloppy_key(key)
      return key if key?(key)
      return key.to_s if key?(key.to_s)
      return key.to_sym
    end

    def method_missing(sym, *args, &block)
      return super if block_given?

      if args.length == 1 && sym.to_s =~ /^(.*)=$/
        return self[lookup_sloppy_key($1)] = args.first
      elsif args.length == 0
        if sym.to_s =~ /^(.*)\?$/
          # Return false if the entry does not exist.
          # Return true if the entry exists and evaluates to false
          # Return the entry otherwise.
          key = lookup_sloppy_key($1)
          return nil if !key?(key)
          return (self[key] || true).slop!
        else
          # fetch the entry, if it exists, or raise an IndexError
          return fetch(lookup_sloppy_key(sym)).slop!
        end
      end
      
      super
    rescue IndexError
      super
    end

    public
        
    def respond_to?(sym)
      super || case sym.to_s
      when /^(.*)[=\?]$/
        true
      else
        key? lookup_sloppy_key(sym)
      end
    end
  end

  def slop!
    extend(Slop)
  end

  def sloppy?
    is_a?(Slop)
  end
end

class Array
  def slop!
    each(&:"slop!")
  end
end

class Object
  def slop
    dup.slop!
  rescue TypeError # e.g. "Can't dup NilClass"
    self
  end
  
  def slop!    
    self
  end
  
  def sloppy?
    false
  end
end

module Hash::Slop::Etest
  def test_slop_hashes
    h = { :a => { "b" => "ccc" }}
    h1 = h.slop!
    assert h.sloppy?
    assert h1.sloppy?
    
    assert_equal("ccc", h.a.b)
    assert h1.object_id == h.object_id

    assert h.a?
    assert !h.b?
    assert h.a.b?
    assert !h.a.c?
  end

  def test_nil_entries
    h = { :a => nil, :b => false, :c => 1 }
    h.slop!
    
    assert_equal true, h.a?
    assert_equal true, h.b?
    assert_equal 1, h.c?
    assert_equal nil, h.d?

    assert_equal nil, h.a
    assert_equal false, h.b
    assert_equal 1, h.c
    assert_raises(NoMethodError) {
      h.d
    }
  end

  def test_slop_hashes_2
    h = { :a => { "b" => "ccc" }}
    h1 = h.slop
    assert !h.sloppy?
    assert h1.sloppy?
    
    assert_equal("ccc", h1.a.b)
    assert h1.object_id != h.object_id

    assert h1.a?
    assert !h1.b?
    assert h1.a.b?
    assert !h1.a.c?
  end

  def test_slop_assigns
    h = { :a => { "b" => "ccc" }}
    h.slop!
    
    h.a = 2
    
    assert_equal({ :a => 2}, h)
    
    h.b = 2
    assert_equal({ :a => 2, :b => 2}, h)

    v = { :c => { :d => 2 } }
    assert !v.sloppy?
    
    h.b = v.dup
    assert_equal(2, h.b.c.d)
    assert !v.sloppy?
    assert h.b.sloppy?
  end
end if VEX_TEST == "base"
