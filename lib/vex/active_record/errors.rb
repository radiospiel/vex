module ActiveRecord::Extension::Errors
  def full_message
    full_messages.join(", ")
  end
end

ActiveRecord::Errors.send :include, ActiveRecord::Extension::Errors
