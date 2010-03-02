module ActiveRecord::ValidationExt

  def self.init
    ActiveRecord::Base.extend ClassMethods
    ActiveRecord::Base.send :include, InstanceMethods
  end

  # this module will be included in ActiveRecord::Validations::ClassMethods,
  # which will be included in ActiveRecord::Base
  module ClassMethods
    
    def attribute_validations
      @attribute_validations ||= {}
    end
    
    class Slate < BlankSlate
      def initialize(attribute_validations)
        @attribute_validations = attribute_validations
      end
      
      def on(attr, &block)
        @attribute_validations[attr] ||= []
        @attribute_validations[attr] << Proc.new
      end
    end
    
    def validates(&block)
      @attribute_validations = {}
      Proc.new.bind(Slate.new(@attribute_validations)).call
    end
  end

  module InstanceMethods

    def validate
      self.class.attribute_validations.each do |attr, procs|
        procs.each { |proc| attribute_validation(attr, proc) }
      end
    end

    private
     
    def attribute_validation(attr, proc)
      r = case proc.arity
      when 1      then proc.bind(self).call(self.send(attr))
      when 0, -1  then proc.bind(self).call
      else        raise ArgumentError, "Unsupported arity on #{proc}"
      end
      
      return if false != r
      errors.add attr, "is invalid"
    rescue 
      errors.add attr, $!.to_s
    end
  end
end


module ActiveRecord::ValidationExt::Etest
  def test_feed_validation_traditional
    assert_raise(ActiveRecord::RecordInvalid) {  
      Feed.create! :keyword => nil, :language => "traditional"
    }

    assert_raise(ActiveRecord::RecordInvalid) {  
      Feed.create! :keyword => "keys", :language => "traditional"
    }

    assert_nothing_raised {  
      Feed.create! :keyword => "22222", :language => "traditional"
    }
  end

  def test_feed_validation_attr1
    assert_raise(ActiveRecord::RecordInvalid) {  
      Feed.create! :keyword => nil, :language => "mode1"
    }

    assert_raise(ActiveRecord::RecordInvalid) {  
      Feed.create! :keyword => "keys", :language => "mode1"
    }

    assert_nothing_raised {  
      Feed.create! :keyword => "22222", :language => "mode1"
    }
  end

  def test_feed_validation_attr2
    assert_raise(ActiveRecord::RecordInvalid) { 
      Feed.create! :keyword => nil, :language => "mode2"
    }

    assert_raise(ActiveRecord::RecordInvalid) {  
      Feed.create! :keyword => "keys", :language => "mode2"
    }

    assert_nothing_raised {  
      Feed.create! :keyword => "22222", :language => "mode2"
    }
  end

  def test_feed_validation_attr3
    assert_raise(ActiveRecord::RecordInvalid) { 
      Feed.create! :keyword => nil, :language => "mode3"
    }

    assert_raise(ActiveRecord::RecordInvalid) {  
      Feed.create! :keyword => "keys", :language => "mode3"
    }

    assert_nothing_raised {  
      Feed.create! :keyword => "22222", :language => "mode3"
    }
  end

end
