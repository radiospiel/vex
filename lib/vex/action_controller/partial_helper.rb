module ActionController::PartialHelper
  def self.disable_localite
    @no_localite = true
  end
  
  def self.localite?
    defined?(Localite) && !@no_localite
  end

  def partial_for(name)
    case name
    when String then  name
    when Array  then  partial_for name.first
    else              "sh/#{name.class.name.underscore}"
    end
  end

  #
  # partial <partial-name>, <object>, <locals> or
  # partial <object>, <locals>
  #
  def partial(partial, object=nil, locals=nil)
    #
    # set up object and locals
    unless partial.is_a?(String) 
      object, locals = partial, object
    end
    if !locals && object.is_a?(Hash)
      locals, object = object, nil
    end
    
    opts = { 
      :partial => partial_for(partial), 
      :locals => locals 
    }
    
    if object
      opts[:object] = object
    elsif locals && locals[:collection]
      opts[:collection] = locals[:collection]
    end
    
    #
    # set up localite??
    if ActionController::PartialHelper.localite? && !(scope = File.basename(partial).gsub(/\..*/, "")).blank?
      Localite.scope(scope) do 
        render_vex_partial(opts)
      end
    else
      render_vex_partial(opts)
    end
  end
  
  def render_vex_partial(opts)
    if self.is_a?(ActionController::Base)
      render_to_string(opts)
    else
      render(opts)
    end
  end

  def partial?(*args)
    partial *args
  rescue ActionView::MissingTemplate
    logger.debug $!.to_s
    nil
  end
end

ActionController::Base.helper ActionController::PartialHelper

class ActionController::Base
  def render_vex_partial(opts)
    render_to_string(opts)
  end
end

class ActionView::Base
  def render_vex_partial(opts)
    render(opts)
  end
end
