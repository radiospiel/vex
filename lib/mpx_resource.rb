class MpxResource < ActiveResource::Base
  MPCP_UPDATE_IN_BACKGROUND = false

  def self.mpx_resource(mpcp_url, name, opts = {})
    self.site = MPCP_URL
    self.timeout = opts[:timout] || 5 
    self.prefix = opts[:prefix] || "/rest/"

    self.collection_name = opts[:collection] || name.to_s.pluralize
    self.element_name = opts[:element] || name.to_s.singularize
  end

  # set the authorization headers 
  def self.headers
    if RAILS_ENV == "test"
      super
    else
      Mpx::Authorization.authorize(super)
    end
  end

  # run a piece of code without caring for the result. If MPCP_UPDATE_IN_BACKGROUND
  # is set this is done in a new thread in the background.
  def self.deferred(run_in_background=true, &block)
    if run_in_background && MPCP_UPDATE_IN_BACKGROUND
      Thread.new { without_server_errors(&block) }
    else
      without_server_errors(&block)
    end

    nil
  end
  
  def deferred(run_in_background=true, &block)
    self.class.deferred(f, &block)
  end

  private
  
  def self.without_server_errors(&block)
    begin
      yield 
    rescue ActiveResource::TimeoutError, ActiveResource::ServerError 
    end
  end
end
