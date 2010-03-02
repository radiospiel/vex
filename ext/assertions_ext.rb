require "test/unit"

module Test::Unit::Assertions
  def assert_respond_to(obj, *args)
    raise ArgumentError, "Missing argument(s)" if args.length < 1
  
    args.reject! { |sym| obj.respond_to?(sym) }
    
    assert args.empty?, "#{obj.inspect} should respond to #{args.map(&:inspect).join(", ")}, but doesn't."
  end

  # returns a list of invalid attributes in a model, as symbols.
  #:nodoc:
  def invalid_attributes(model)
    model.valid? ? [] : model.errors.instance_variable_get("@errors").keys.map(&:to_sym)
  end
  
  #
  # Verifies that a model is valid. Pass in some attributes to only
  # validate those attributes.
  def assert_valid(model, *attributes)
    if attributes.empty?
      assert(model.valid?, "#{model.inspect} should be valid, but isn't: #{model.errors.full_messages.join(", ")}.")
    else
      invalid_attributes = invalid_attributes(model) & attributes
      assert invalid_attributes.empty?,
        "Attribute(s) #{invalid_attributes.join(", ")} should be valid"
    end
  end

  #
  # Verifies that a model is invalid. Pass in some attributes to only
  # validate those attributes.
  def assert_invalid(model, *attributes)
    assert(!model.valid?, "#{model.inspect} should be invalid, but isn't.")
    
    return if attributes.empty?

    missing_invalids = attributes - invalid_attributes(model)

    assert missing_invalids.empty?,
      "Attribute(s) #{missing_invalids.join(", ")} should be invalid, but are not"
  end
end

module Test::Unit::Assertions::Etest
  def test_for_the_sake_of_rcov
    assert_respond_to 1, :to_s
    assert_respond_to 1, :to_s, :to_s    
  end
end

