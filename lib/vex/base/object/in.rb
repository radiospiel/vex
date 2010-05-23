#
# short inspect method on all objects.
#
# "abcdefghijklmnopabcdefghijklmnopabcdefghijklmnopabcdefghijklmnop".insp
#    -> "abcdefghijklmnopabcdefghijk..."
# Model.find(1).insp 
#    -> "<Model#1>"

module Object::InMethod
  def in?(collection)
    collection.include?(self)
  end
end

class Object
  include InMethod
end

module Object::InMethod::Etest
  def test_in
    assert_equal true, "1".in?(%w(1 2 3))
    assert_equal false, 1.in?(%w(1 2 3))
    assert_equal false, 1.in?([])
  end
end if VEX_TEST == "base"
