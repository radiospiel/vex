#
# This module adds some logging functions. Log entries contain a timestamp,
# the log severity, information about the environment at log time  
#
# Enable logging for a class, all subclasses, and al instances level
#
#   class X
#     advanced_logger
#     advanced_logger RAILS_DEFAULT_LOGGER
#     advanced_logger "filename"
#     advanced_logger "/var/log/tmpfilename"
#   end
#
# Block level logging:
#
#   logged [ severity ], arguments do 
#     ...
#   end
# 
# Single line logging:
#
#   log [ severity ], arguments
# 
module AdvancedLogging
  
  SEVERITIES = [
    :debug,
    :info,
    :warn,
    :fatal
  ]
  
  #
  # This defines a logger method on a class, and adds all logging methods
  # to the class and to all instances.
  module ForClass
    def advanced_logger(log=nil)
      # The log file name defaults to the class name, w/o any namespace.
      log ||= "#{self.to_s.underscore.sub(/.*\//, "")}.log" 

      extend AdvancedLogging::Methods
      include AdvancedLogging::Methods

      logger = AdvancedLogging.resolve_log(log)

      define_object_method :logger do
        logger
      end
    end
  end

  #
  # This defines a default to_s implementation for ActiveRecord models
  module ForAR_Base
    def to_s
      "<#{self.class}##{self.id}>"
    end
  end

  module Methods
    def debug(*args)
      log(:debug, *args)
    end
    
    def info(*args)
      log(:info, *args)
    end
    
    def warn(*args)
      log(:warn, *args)
    end
    
    def fatal(*args)
      log(:fatal, *args)
    end
    
    def logger
      self.class.logger
    end
      
    def log(*args)
      AdvancedLogging.do_log(self, nil, args)
    end

    def logged(*args, &block)
      raise "Missing block" unless block_given?

      start = Time.now

      begin
        r = yield
        AdvancedLogging.do_log self, nil, args, " (#{"%.3f" % (Time.now - start)} secs)"
        r
      rescue
        AdvancedLogging.do_log self, :warn, args, " failed after #{"%.3f" % (Time.now - start)} secs: #{$!}  "
        raise
      end
    end
  end
  
  # -- implementation -------------------------------------------------

  def self.resolve_log(log)
    case log
    when String
      log = File.join(RAILS_ROOT, '/log/', log) unless log.starts_with?("/")
      ActiveSupport::BufferedLogger.new(log)
    when Module, Class
      log.logger
    else
      log
    end
  end

  def self.is_severity?(s)
    SEVERITIES.include?(s)
  end

  def self.do_log(obj, min_severity, args, status=nil)
    severity = is_severity?(args.first) ? args.shift : :info
    severity = combine_severities(severity, min_severity)
    status = " #{status}" if status

    if obj.logger.respond_to? :do_log
      obj.logger.do_log severity, "#{format_message(args)}#{status}"
    else
      obj.logger.send severity, 
        "[#{Time.now.to_s(:db)}]  [#{severity.to_s.capitalize}] #{obj}: #{format_message(args)}#{status}"
    end
  end
  
  def self.combine_severities(severity, min_severity)
    return severity if min_severity.nil?

    severity_idx = SEVERITIES.index(severity)
    if !severity_idx || SEVERITIES.index(min_severity) > SEVERITIES.index(severity)
      severity = min_severity
    end
  end

  def self.format_message(args)
    args.collect do |arg|
      case arg
      when String, ActiveRecord::Base then arg.to_s
      else arg.inspect
      end
    end.join(", ")
  end

  def self.init
    @init ||= begin
      Module.__send__ :include, ForClass
      ActiveRecord::Base.__send__ :include, ForAR_Base
      true
    end
  end
end

AdvancedLogging.init

module AdvancedLogging::Etest
  class X
    advanced_logger
  end
  
  class Y
    advanced_logger X
  end
  
  def test_log_for_class
    x=X
    x.log "x"
    x.debug "x"
    x.info "x"
    x.warn "x"
    x.fatal "x"
  end
  
  def test_log_for_object
    x=X.new
    x.log "x"
    x.debug "x"
    x.info "x"
    x.warn "x"
    x.fatal "x"
  end

  def test_logged
    y = 0
    X.logged "Hey" do
      y = 1
    end
  
    assert_equal(1, y)

    assert_raise(RuntimeError) {
      X.logged "Failed" do
        raise "filaed"
      end
    }
  end
end
