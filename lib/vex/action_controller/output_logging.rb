module ActionController::OutputLogging
  def with_output_logging
    around_filter ActionController::OutputLogging
  end

  def self.filter(controller, &block)
    yield
    do_output_logging controller, nil
  rescue
    do_output_logging controller, $!
  end
    
  def self.do_output_logging(controller, exception)
    msg = []
      
    msg << "#{Time.now}: #{controller.request.query_string}"
    msg << (controller.params.to_a.sort_by(&:first).map { |k,v| "  #{k}: #{v.inspect}"}).join("\n")
    msg << "Caught exception #{exception.inspect}" if exception
    msg << controller.response.body
    msg = msg.join("\n" + "-" * 80 + "\n") + "\n" + "=" * 80

    logger.warn msg
  end
    
  def self.logger
    @logger ||= ActiveSupport::BufferedLogger.new "#{RAILS_ROOT}/log/output.log"
  end
end

ActionController::Base.extend ActionController::OutputLogging
