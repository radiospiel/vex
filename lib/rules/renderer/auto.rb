class Rules::Renderer::Auto
  
  def render(rules, model)
    # Note: case doesn't work here: it doesn't deal with AssocProxies 
    if model.is_a?(Array)                 then render_array(rules, model)
    elsif model.is_a?(ActiveRecord::Base) then render_model(rules, model)
    else                                       render_plain(rules, model)
    end
  end

  private
  
  def render_array(rules, content)
    return nil if content.empty?

    content = content.map { |m| render_li(rules, m) }.compact
    return nil if content.empty?
    
    content_tag("ul") do
      content.join
    end  
  end
  
  def render_model(rules, model)
    css = model.class.name.underscore
    
    if attributes = rules["attributes"]
      attributes = attributes.split(" ")
    else
      attributes = model.attribute_names.reject { |k| k.ends_with?("_id") }
      attributes += model.class.reflect_on_all_associations.map { |ass| ass.name.to_s }
      attributes.sort!
      attributes.unshift("id") if attributes.delete("id")
    end

    return nil if attributes.empty?

    content = attributes.map { |m|
      render_li(rules, model.send(m), m)
    }.compact
    
    return nil if content.empty?
    
    content_tag("ul", :class => css) do
      content.join
    end  
  end
  
  def render_plain(rules, model)
    "<span class='v'>#{h(model)}</span>"
  end
  
  def render_li(rules, model, name=nil)
    return if rules.rendered?(model)
    return unless html = rules.render(model, name)

    content_tag :li, :class => name do
      case label = rules.with_model(model, name) { rules["label"] }
      when "none" then label = nil
      when nil    then label = (name && name.camelize) 
      end

      n = "<em>#{label}</em>" if label
      "#{n}#{html}"
    end
  end

  def h(s)
    ERB::Util::h(s.to_s)
  end

  def content_tag(tag, opts = {}, &block)
    content = yield
    
    opts = opts.map { |k,v| v && " #{k}='#{h(v)}'" }.compact.join
    "\n<#{tag}#{opts}>#{yield}</#{tag}>"
  end
end
