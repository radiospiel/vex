module ActiveRecord::Conditions
end

__END__

module ActiveRecord::Conditions
  class C < Array
    def initialize(base)
      @base = base
    end
  
    def apply(*args)
      push @base.send(:sanitize_sql, args)
    end
  
    def to_condition(mode = "and")
      "(" + join(") #{mode} (") + ")"
    end
  end
  
  def conditions(mode, &block)
    c = C.new(self)
    Proc.new.bind(c).call
    c.to_condition(mode)
  end
end
