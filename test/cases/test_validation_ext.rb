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
end
