module ActionController::Error

  # I don't know why we have to pack the parameters into an array.
  class Exception < RuntimeError
    attr_reader :code, :text
    
    def initialize(args)
      @code, @text = *args
    end
  end
  
  def error(code, text=nil)
    raise Exception, [ code, text ]
  end
  
  def self.included(base)
    base.rescue_from ActionController::Error::Exception, :with => :rescue_custom_exceptions
    base.rescue_from ActionController::Error::Exception, :with => :rescue_custom_exceptions
    base.rescue_from ActionController::RoutingError, :with => :rescue_404
    base.rescue_from ActionController::UnknownAction, :with => :rescue_404
  end

  private

  def rescue_404
    @text = "You may have mistyped the address or the page may have moved."
    render :layout => "layouts/404", :text => "", :status => 404
  end
  
  def rescue_custom_exceptions(e = 404)
    if e.code == 404
      @text = e.text || "You may have mistyped the address or the page may have moved."
      render :layout => "layouts/404", :text => "", :status => 404
    elsif e.text.blank?
      render(:status => code, :nothing => true)
    else
      render(:status => code, :text => e.text.to_s, :content_type => "text/plain")
    end
  end
end

class ActionController::Base
  include ActionController::Error
end
