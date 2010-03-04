module Hash::Extract
  def extract(*args)
    extract_mapped(:[], *args)
  end

  # i.e. extract_and_delete
  def extract!(*args)
    extract_mapped(:delete, *args)
  end

  private

  def extract_mapped(sym, *args)
    translate = args.extract_options!

    hash = args.inject({}) do |hash, k|
      hash.update k => self.send(sym, k) if has_key?(k)
      hash
    end

    translate.inject(hash) do |hash, (k, v)|
      if has_key?(k)
        value = self.send(sym, k) 
        hash.update v => value unless v.nil?
      end
      hash
    end
  end
end

class Hash
  include Extract
end

module Hash::Extract::Etest
  def test_extract
    h = { :a => "1", :b => "2" }
    assert_equal(h.extract(:a, :c), {:a => "1"})
  end

  def orig
    { 1 => 2, 3 => 4, 5 => 6}
  end

  def test_extract_w_delete!
    h = orig
    assert_equal ({1=>2}), h.extract!(1, 2, 3 => nil)
    assert_equal ({5 => 6}), h
  end

  def test_extract!
    h = orig
    assert_equal ({1=>2, 3 => 4}), h.extract!(1, 2, 3)
    assert_equal ({5 => 6}), h

    h = orig
    assert_equal ({1=>2, :a => 4}), h.extract!(1, 2, 3 => :a)
    assert_equal ({5 => 6}), h
  end

  def test_extract2
    assert_nothing_raised {  
      h = orig.freeze
      assert_equal ({1=>2, 3 => 4}), h.extract(1, 2, 3)
      assert_equal orig, h

      assert_equal ({1=>2, :a => 4}), h.extract(1, 2, 3 => :a)
      assert_equal orig, h
    }
  end
end if VEX_TEST == "base"
