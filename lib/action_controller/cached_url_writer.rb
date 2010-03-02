module ActionController::CachedUrlWriter

  def self.included(klass)
    klass.alias_method_chain :url_for, :cached
  end
  
  def url_for_with_cached(options = {})
#    return url_for_without_cached(options)
    options = options.dup

    # take out all parameters that would resolve into a param id
    parameters = {}

    options.each do |k,v|
      case v
      when Fixnum             then parameters.update k => v
      when ActiveRecord::Base then parameters.update k => v.id
      end
    end
    
    if parameters.empty?
      return url_for_without_cached(options)
    end
    
    parameters.keys.each do |key|
      options[key] = "---#{key}---"
    end

    @url_for_cache ||= {}
    pattern = (@url_for_cache[options] ||= url_for_without_cached(options))

    pattern.gsub(/---([^-]+)---/) do |key|
      parameters[key]
    end
  end
end
