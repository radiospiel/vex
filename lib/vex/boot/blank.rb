class Object
  def blank?
    false
  end
end

class NilClass
  def blank?
    true
  end
end

class FalseClass
  def blank?
    true
  end
end

module Enumerable
  def blank?
    empty?
  end
end

class String
  alias :blank? :empty?
end

module Blank
  module Etest
    def test_blanks
      assert_equal true, nil.blank?
      assert_equal true, [].blank?
      assert_equal true, false.blank?
      assert_equal true, {}.blank?
      assert_equal true, "".blank?

      assert_equal false, 1.blank?
    end
  end
end if VEX_TEST == "boot"