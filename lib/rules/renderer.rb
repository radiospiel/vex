class Rules::Renderer
  attr :rules
  attr :position
  
  def initialize(rules)
    @rules, @position, @models = rules, [], []
  end
  
  def action_view
    rules.action_view
  end
  
  def renderer
    name = self["render"] || "auto"
    if name =~ /^([^(]+)\(([^)]+)\)$/
      name, arg = $1, $2
    end

    # get renderer class
    klass = "#{self.class}::#{name.camelize}".constantize
    
    # get renderer instance
    arg ? klass.new(arg) : klass.new
  end
  
  def rendered?(model)
    @models.include?(model)
  end

  def with_model(model, name=nil)
    begin
      @models << model
      klass = model.is_a?(Symbol) ? model : model.class.name.underscore
      @position << [klass, name]
      yield
    ensure
      @position.pop
      @models.pop
    end
  end
  
  def render(*args)
    if args.first.is_a?(Symbol)
      return with_model(args.shift) do
        render *args
      end
    end
    
    raise ArgumentError, "Too many arguments" unless args.length <= 2
    
    model, name = *args
    
    with_model(model, name) do
      renderer.render(self, model)
    end
  end
  
  def [](key)
    rules.send(:fetch, position, key)
  end
end
