#
# short inspect method on all objects.
#
# "abcdefghijklmnopabcdefghijklmnopabcdefghijklmnopabcdefghijklmnop".insp
#    -> "abcdefghijklmnopabcdefghijk..."
# Model.find(1).insp 
#    -> "<Model#1>"

class Object
  def in?(collection)
    collection.include?(self)
  end
end
