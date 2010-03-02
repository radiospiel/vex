class Rules::Renderer::Template
  def initialize(template=nil)
    @template = template
  end
  
  def render(rules, model)
    template = @template || "rules/#{model.class.name.underscore}"
    rules.action_view.render :partial => template, :object => model
  end
end
