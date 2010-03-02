module ActiveRecord::ValidationErrorExt

  def self.included(base)
    ActiveRecord::Errors.send :include, ErrorsExt
    ActiveRecord::Errors.alias_method_chain :add, :unique_messages
  end
  
  # better error reporting: this is useful mainly for development cycles, as
  # it adds an error message only once
  module ErrorsExt
    def delete(entry)
      @errors.delete entry.to_s
    end

    def add(attribute, message = nil, options = {})
      add_with_unique_messages(attribute, message, options)
    end

    def add_with_unique_messages(error_or_attr, message = nil, options = {})
      if error_or_attr.is_a?(ActiveRecord::Error)
        error, attribute = error_or_attr, error_or_attr.attribute
      else
        attribute = error_or_attr
        error = ActiveRecord::Error.new(@base, attribute, message, options)
      end
      
      options[:message] = options.delete(:default) if options.has_key?(:default)

      @errors[attribute.to_s] ||= []

      existing = @errors[attribute.to_s].detect do |err|
        err.message == message
      end
      
      existing || (@errors[attribute.to_s] << error)
    end
  end
end

module ActiveRecord::ValidationExt::Etest
  def test_single_adds
    obj = Programme.new

    obj.errors.add "x", "xxx"
    assert_kind_of(String, obj.errors["x"])

    obj.errors.add "x", "xxx"
    assert_kind_of(String, obj.errors["x"])

    obj.errors.add "x", "yyyy"
    assert_equal(%w(xxx yyyy), obj.errors["x"])

    obj.errors.add "x", "yyyy"
    assert_equal(%w(xxx yyyy), obj.errors["x"])

    obj.errors.add "x", "xxx"
    assert_equal(%w(xxx yyyy), obj.errors["x"])

    obj.errors.add "x", "zzz"
    assert_equal(%w(xxx yyyy zzz), obj.errors["x"])
  end
end
