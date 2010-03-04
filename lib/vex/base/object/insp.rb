#
# short inspect method on all objects.
#
# "abcdefghijklmnopabcdefghijklmnopabcdefghijklmnopabcdefghijklmnop".insp
#    -> "abcdefghijklmnopabcdefghijk..."
# Model.find(1).insp 
#    -> "<Model#1>"

class Object
  def insp
    body = "#{insp_body}"
    body = ": #{body}" unless body.empty?
    "#{insp_head}#{body}#{insp_close}"
  end

  private

  def insp_head; "<#{self.class}@#{self.object_id}"; end
  def insp_body; end
  def insp_close; ">"; end
end

[ Numeric, TrueClass, FalseClass, NilClass, Symbol, Module ].each do |klass|
  klass.send :alias_method, :insp, :inspect
end

class String
  INSP_TRUNCATE_LEN = 30

  def insp
    return inspect unless length > INSP_TRUNCATE_LEN
    
    l = INSP_TRUNCATE_LEN - 3
    (self[0...l].to_s + "...").inspect
  end
end

if defined?(ActiveRecord)
  class ActiveRecord::Base
    private
  
    def insp_head; "<#{self.class}##{self.id}"; end
  end
end

class Hash
  def insp
    self.class == Hash && instance_variables.empty? ? insp_body : super
  end

  private

  INSP_TRUNCATE_LEN = 10

  def insp_body
    body = to_a.sort { |a,b|
      a <=> b rescue a.to_s <=> b.to_s
    }

    if length > INSP_TRUNCATE_LEN
      body = body[0...INSP_TRUNCATE_LEN]
      more = ", ... (#{length - INSP_TRUNCATE_LEN} more)"
    end

    "{#{body.map { |k,v| "#{k.insp} => #{v.insp}"}.join(", ")}#{more}}"
  end
end

class Array
  def insp
    self.class == Array && instance_variables.empty? ? insp_body : super
  end

  private

  INSP_TRUNCATE_LEN = 20

  def insp_body
    if length > INSP_TRUNCATE_LEN
      body = self[0...INSP_TRUNCATE_LEN]
      more = ", ... (#{length - INSP_TRUNCATE_LEN} more)"
    end

    "[#{(body || self).map(&:insp).join(", ")}#{more}]"
  end
end

module Insp; end

module Insp::Etest
  def test_insp_array
    assert_equal("[1, 2]", [1,2].insp)
    assert_equal("[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, ... (10 more)]", (1..30).to_a.insp)
  end
  
  def test_insp_hash
    assert_equal("{}", {}.insp)

    h = (1..30).to_a.inject({}) do |hash, id| 
      hash.update id => id*id
    end
    assert_equal "{1 => 1, 2 => 4, 3 => 9, 4 => 16, 5 => 25, 6 => 36, 7 => 49, 8 => 64, 9 => 81, 10 => 100, ... (20 more)}", 
      h.insp
  end

  def test_insp_string
    s = "123"
    assert_equal(s.insp, s.inspect)
    s = (s * 100).insp
    assert s.ends_with?("...\"")
    assert s.length < 50
  end

  class X
    def initialize
      @x = "x"
    end
  end
  
  def test_insp_obj
    assert X.new.insp =~ /Insp::Etest::X/
  end
end if VEX_TEST == "base"
