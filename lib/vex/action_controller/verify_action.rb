# This module adds/modifies ActionController::Verification. It adds 
#
# - adds verify? and verify, which verifies conditions on a per action
#   base. On error the former returns false, while the latter raises
#   an exception.
# - adds improved error messages
# 
module ActionController::VerifyAction
  class Error < ArgumentError; end

  def self.fail(options, better_msg=nil)
    msg = "Action verification failed: #{options.inspect}"
    msg += " #{better_msg}" if better_msg
    
    raise Error, "#{msg}."
  end

  private
  
  def fail(*args)
    ActionController::VerifyAction.fail(*args)
  end

  # Rails 2.3's verify_action method does NOT return a value. Instead it
  # 'executes' the add_flash, add_headers, render, and/or redirect_to 
  # options. We raise an additional exception here for a failed verification, 
  # which is to be catched later on to return true or false.
  #
  def apply_remaining_actions(options) # :nodoc:
    super
    fail(options)
  end

  # Override Rails' verify_action
  def verify_action(opts, catch_error = true)
    begin
      super(opts)
      true
    rescue Error
      raise unless catch_error
      false
    end
  end

  def verify?(opts)
    verify_action(opts, true)
  end
  
  def verify(opts)
    verify_action(opts, false)
  end

  # -- Reimplements Rails' verifications to add better error messages

  def verify_presence_of_keys_in_hash(options, entry, hash) # :nodoc:
    return unless keys = options[entry]
    missing = if keys.is_a?(Array)
      keys.find { |v| hash[v].nil? }
    elsif hash[keys].nil?
      keys
    end 
    
    return unless missing
    
    fail(options, "Missing key #{missing.inspect} in #{entry}")
  end
  
  def verify_presence_of_keys_in_hash_flash_or_params(options) # :nodoc:
    verify_presence_of_keys_in_hash(options, :params, params) ||
    verify_presence_of_keys_in_hash(options, :session, session) ||
    verify_presence_of_keys_in_hash(options, :flash, flash)
  end
  
  def verify_method(options) # :nodoc:
    methods = options[:method]
    return if methods.nil?

    if methods.is_a?(Array)
      return if methods.include?(request.method)
      return if methods.include?(request.method.to_s)
    else
      return if request.method == methods.to_sym
    end
     
    fail(options, "Invalid request method #{request.method}")
  end
  
  def verify_request_xhr_status(options) # :nodoc:
    return if options[:xhr].nil?
    return if request.xhr? == options[:xhr]
    fail(options, "Unsupported XHR state #{request.xhr?}")
  end
end

class ActionController::Base
  include ActionController::VerifyAction
end
