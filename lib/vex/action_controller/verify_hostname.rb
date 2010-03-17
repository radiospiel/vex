module ActionController::VerifyHostname
  def verify_hostname(matcher=nil, &block)
    matcher ||= Proc.new
    
    before_filter do |controller|
      host = controller.request.host
      case matcher
      when String 
        next if matcher == host
      when Regexp 
        next if matcher.match(host)
      when Proc
        next if matcher.call(host)
      end

      msg = "Not on #{host}"
      
      msg += "; should have matched #{matcher.inspect}" if App.development?
        
      controller.error 404, msg + "\n"
    end
  end
end

class ActionController::Base
  extend ActionController::VerifyHostname
end
