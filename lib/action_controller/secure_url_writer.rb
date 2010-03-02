module ActionController::SecureUrlWriter

  SECRET=defined?(LocalConf) ? LocalConf.safe_token : "LocalConf.safe_token"

  def self.included(klass)
    klass.extend ClassMethods
    klass.alias_method_chain :url_for, :sct
  end

  module ClassMethods
    def with_secure_url(options = {})
      @with_secure_url = options.to_a.
        inject({}) do |hash, (k,v)|
          if v.is_a?(Array)
            v = v.map(&:to_sym)
          else
            v = v.to_sym
          end
          hash.update k => v
        end

      before_filter :validate_secure_url, options
    end

    def with_secure_url?(action_name)
      return false unless @with_secure_url

      def match(action_name, entry)
        return true if entry == action_name
        entry.is_a?(Array) && entry.include?(action_name)
      end
      
      action_name = action_name.to_sym
      if only = @with_secure_url[:only]
        match(action_name, only)
      elsif except = @with_secure_url[:except]
        !match(action_name, except)
      else
        true
      end
    end
  end

  private
  
  def resolve_controller(name)
    return self.class unless name
    "#{name}_controller".camelize.constantize rescue nil
  end

  public
  
  def url_for_with_sct(options = {})
    url = url_for_without_sct(options)

    return url unless options.is_a?(Hash)

    controller = resolve_controller(options[:controller])
    return url unless controller
    return url unless controller.with_secure_url?(options[:action] || action_name)

    path = url.gsub(/^http(s)?:\/\/[^\/]+/, "")
    token = Digest::SHA1.hexdigest("#{SECRET}-#{path}")

    if url.index("?")
      url + "&sct=#{token}"
    else
      url + "?sct=#{token}"
    end
  end

  def validate_secure_url
    if (url = request.request_uri) =~ /(.*)[\?&]sct=([0-9a-z]+)$/
      path, token = $1, $2
      return if token == Digest::SHA1.hexdigest("#{SECRET}-#{path}")
    end
    
    forbidden
  end
end


if defined?(WillPaginate)
  class WillPaginate::LinkRenderer

    # Returns URL params for +page_link_or_span+, taking the current GET params
    # and <tt>:params</tt> option into account.
    def url_for(page)
      page_one = page == 1
      @url_params = {}
      # page links should preserve GET parameters
      stringified_merge @url_params, @template.params if @template.request.get?
      stringified_merge @url_params, @options[:params] if @options[:params]

      if param_name.index(/[^\w-]/)
        page_param = parse_query_parameters("#{param_name}=#{page}")
        stringified_merge @url_params, page_param
      else
        @url_params[param_name] = page
      end

      @template.url_for(@url_params)
    end
  end
end
