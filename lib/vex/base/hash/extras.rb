module Hash::Extras
  def self.included(klass)
    klass.extend ClassMethods
  end
  
  module ClassMethods
    def create(keys, values)
      self[*keys.zip(values).flatten]
    end
  end

  # compare 
  def hmap(&block)
    self.inject({}) { |h, i|
      h.update i[0] => yield(i[0], i[1])
      h
    }
  end

  def delete_all(*args)
    args.inject([]) do |array, arg|
      array << delete(arg)
    end
  end  

  def select_entries(*args)
    args.inject([]) do |array, arg|
      array << self[arg]
    end
  end  
end

class Hash
  include Extras
end

module Hash::Extras::Etest
  def test_create
    h = Hash.create([:a, :b], ["aa", "bb"])
    
    assert_equal({ :a => "aa", :b => "bb"}, h)
  end
  
  def test_hmap
    h = { 1 => "a", 2 => "b" }
    assert_equal({ 1 => "a", 2 => "bb"}, h.hmap do |k,v| v * k end)
  end
  
  def test_delete_all
    h = { 1 => "a", 2 => "b" }
    assert_equal([ "a", nil ], h.delete_all(1, 3))
    assert_equal({ 2 => "b"}, h)
  end
  
  def test_select
    h = { 1 => "a", 2 => "b" }
    h_orig = h.dup
    
    assert_equal([ "a", nil ], h.select_entries(1, 3))
    assert_equal(h_orig, h)
  end
end if VEX_TEST == "base"
