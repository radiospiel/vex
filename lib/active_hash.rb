class ActiveHash
  def initialize(values={}, &block)
    @hash = Hash[values]
    @hash.with_simple_access

    @on_write = Proc.new
  end
  
  def [](key)
    @hash[key.to_s]
  end
  
  def []=(key, val)
    @hash[key.to_s] = val
    @on_write.call(key.to_s, val)
  end
  
  def update(other)
    other.each do |k,v|
      self[k] = v
    end
    self
  end
  
  def delete(key)
    v = @hash.delete(key.to_s)
    @on_write.call(key, nil)
    v
  end
  
  def to_json
    @hash.to_json
  end
  
  def to_hash
    @hash
  end
  
  def ==(other)
    to_hash == other.to_hash
  end
  
  def method_missing(*args, &block)
    to_hash.send *args, &block
  end
end

module ActiveHash::Etest
  def test_on_write
    kk = vv = nil
    h = ActiveHash.new(:a => "abc") do |k,v|
      kk, vv = k, v 
    end

    h["b"] = "bb"
    assert_equal(["b", "bb"], [kk, vv])
    assert_equal("bb", h["b"])
    h[:c] = "cc"
    assert_equal(["c", "cc"], [kk, vv])
    assert_equal({:a => "abc", "b" => "bb", "c" => "cc"}, h)    

    keys = h.keys.sort_by(&:to_s)
    
    assert_equal([:a, "b", "c"], keys)
  end 

  def test_delete
    kk = vv = nil
    h = ActiveHash.new do |k,v|
      kk, vv = k, v 
    end

    h[:a] = "abc"
    h["b"] = "bb"
    assert_equal(["b", "bb"], [kk, vv])
    h.delete "b"
    assert_equal(["b", nil], [kk, vv])
    
    assert_equal(["a"], h.keys)

    h.delete "a"
    assert_equal(["a", nil], [kk, vv])
    
    assert_equal([], h.keys)
    assert(h.empty?)
  end 

  def test_update
    kk = vv = nil
    h = ActiveHash.new do |k,v|
      kk, vv = k, v 
    end
    h.update :a => "abc", "b" => "bb"
    assert_equal({"a"=>"abc", "b"=>"bb"}, h)
    assert_not_nil(kk)
    assert_not_nil(vv)
  end 
end
