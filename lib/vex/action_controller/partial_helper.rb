module ActionController::PartialHelper
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
