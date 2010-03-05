
# better error reporting: this is useful mainly for development cycles, as
# it adds an error message only once
module ActiveRecord::Errors::Unique

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

class ActiveRecord::Errors
  include Unique
  alias_method_chain :add, :unique_messages
end

module ActiveRecord::Errors::Unique::Etest
  ActiveRecord::Base.connection.create_table :error_models do |t|
    t.integer :value
  end
  
  class ErrorModels < ActiveRecord::Base
  end
  
  def test_single_adds
    obj = ErrorModels.new

    obj.errors.add "value", "xxx"
    assert_kind_of(String, obj.errors["value"])

    obj.errors.add "value", "xxx"
    assert_kind_of(String, obj.errors["value"])

    obj.errors.add "value", "yyyy"
    assert_equal(%w(xxx yyyy), obj.errors["value"])

    obj.errors.add "value", "yyyy"
    assert_equal(%w(xxx yyyy), obj.errors["value"])

    obj.errors.add "value", "xxx"
    assert_equal(%w(xxx yyyy), obj.errors["value"])

    obj.errors.add "value", "zzz"
    assert_equal(%w(xxx yyyy zzz), obj.errors["value"])
  end
end if VEX_TEST == "active_record"
