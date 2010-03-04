module Deep
  KEYS = 0x01
  VALUES = 0x02

  #
  # deep mapping
  def self.map(o, mode, &block)
    case o
    when Hash
      o.inject({}) do |hash, (k,v)|
        k = yield(k) if (mode & KEYS) != 0
        v = map(v, mode, &block)
        hash.update k => v
        hash
      end
    when Array
      if mode & VALUES
        o.map do |v|
          map(v, mode, &block)
        end
      else
        o.dup
      end
    else
      if (mode & VALUES) != 0
        yield o 
      else
        o
      end
    end
  end

  #
  # deep reject
  def self.reject(o, mode, &block)
    case o
    when Hash
      o.inject({}) do |hash, (k,v)|
        next hash if (mode & KEYS) && yield(k)
        v = reject v, mode, &block
        next hash if (mode & VALUES) && yield(v)
        hash.update k => v
        hash
      end
    when Array
      if mode & VALUES
        o.inject([]) do |r, v|
          v = reject(v, mode, &block)
          r << v unless yield(v)
        end
      else
        o.dup
      end
    else
      o
    end
  end
end

module Enumerable
  KEYS = Deep::KEYS
  VALUES = Deep::VALUES

  def reject_blanks
    Deep.reject(self, KEYS | VALUES) do |s|
      s.blank?
    end
  end

  def camelize
    Deep.map(self, KEYS) do |s|
      s.to_s.camelize
    end
  end
end

module Deep::Etest
  def test_reject_blanks
    h = { :a => "a", :b_c => { :d => nil, :video_test => "video_test "}, "x" => nil, "y" => [] }
    expected = { :a=>"a", :b_c => { :video_test => "video_test " }}
    assert_equal(expected, h.reject_blanks)
  end

  def test_camelized_keys
    h = { :a => "a", :b_c => { :d => "dd", :video_test => "video_test "}}
    expected = { "A"=>"a", "BC" => { "VideoTest" => "video_test ", "D" => "dd" }}
    assert_equal(expected, h.camelize)
  end

  def test_missin_block
    assert_raise(LocalJumpError) {
      Deep.reject(%w(1 2), 3)
    }
  end
end if VEX_TEST == "base"
