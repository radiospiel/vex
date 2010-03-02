class Rules < Hash; end

__END__

class Rules < Hash
  class InvalidRule < ArgumentError; end

  attr :action_view
  
  def initialize(action_view)
    raise ArgumentError, "Parameter must be ActionView::Base" unless action_view.is_a?(ActionView::Base)
    @action_view = action_view
  end
  
  def merge(rules)
    return unless rules
    
    rules.each do |addr, value|
      e = (self[addr] ||= {})
      e.update(value)
    end
    
    @cached = @sorted = nil
  end
  
  #
  # compiles a set of rules. Returns a list
  #   [ address_matcher, (hash of key/values) ]
  #
  def self.compile(rule)
    return nil unless rule
    
    rules = rule.gsub(/\/\*([^*]*)\*\//, ""). # C-style. FIXME: this allows no '*' inside a comment 
      gsub(/\/\/.*/, "").                     # C++-style.
      split(/\}/).
      reject(&:blank?)
    
    rules.map { |rule|
      raise InvalidRule, "Invalid rule set #{rule.inspect}" unless rule =~ /^\s*([^{]+)\{\s*([^}]+)$/

      address, rule = $1, $2
      address = AddressMatcher.new(address)
    
      # build data hash
      hash = rule.gsub(/\s+$/, "").split(/;/).inject({}) do |hash, r|
        next hash if r.blank?
      
        raise InvalidRule, "Invalid rule #{r.inspect}" unless r =~ /^\s*(\S+)\s*:\s*(.*)$/
        hash.update $1 => $2
      end

      [ address, hash ]
    }
  end
  
  def compile(*rules)
    rules.each do |rule|
      merge(self.class.compile(rule))
    end
    
    self
  end

  # returns the rule with the name \a key for a certain \a position
  # (Note: the position is an array of models starting at the top model
  # down to the current model.)
  
  def fetch(position, key=nil)
    return fetch(position)[key] if key

    @sorted ||= to_a.sort_by do |a, (k,v)| a.weight end
    @cached ||= {}

    position = AddressMatcher.compile_address(position)
    @cached[position] ||= begin
      # STDERR.puts "Rule #{self.object_id}: Searching for #{position}"
      @sorted.inject({}) { |h, (address, values)| 
        next h unless address.match?(position)
        h.update(values)
      }
    end
  end

  def render(*args)
    renderer.render(*args)
  end
  
  def renderer
    Renderer.new(self)
  end
end

__END__

module Rules::Etest
  def test_1
    rules = Rules.new <<-RULES
      .recommendation {
        render: show
      }
    
      .recommendation .id {
        render: hide(me)
      }

      .recommendation /_id$/ {
        render: hide
      }

      .book {
        render: template(shared/book)
      }
RULES

    assert_equal "hide(me)",              rules.fetch(%w(recommendation id), "render")
    assert_equal "hide",                  rules.fetch(%w(recommendation x_id), "render")
    assert_equal nil,                     rules.fetch(%w(x_id), "render")
    assert_equal nil,                     rules.fetch(%w(x_id_y), "render")
    assert_equal "show",                     rules.fetch(%w(recommendation), "render")
    assert_equal "template(shared/book)", rules.fetch(%w(book), "render")

    assert_equal nil,                     rules.fetch(%w(recommendation), "xyz")
  end
end
