#
# short inspect method on all objects.
#
# "abcdefghijklmnopabcdefghijklmnopabcdefghijklmnopabcdefghijklmnop".insp
#    -> "abcdefghijklmnopabcdefghijk..."
# Model.find(1).insp 
#    -> "<Model#1>"

module Deprecation
  def self.quiet
    @quiet = true
    yield
  ensure
    @quiet = false
  end

  def self.seen
    @seen ||= {}
  end
  
  def self.report(msg, instead=nil)
    return if App.env == "production"
    return if @quiet
    return if seen[[msg, instead]]

    seen[[msg, instead]] = true
    
    msg = "#{msg} is deprecated"
    msg += "; use #{instead} instead" if instead
    msg += ". From\n\t" + caller[1,4].join("\n\t")
    STDERR.puts msg
  end
end

module Deprecation::Etest
  def test_report
    STDERR.expects(:puts)
    Deprecation.report "Hey"
    Deprecation.report "Hey"
  end
end