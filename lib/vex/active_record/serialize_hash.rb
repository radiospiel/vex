__END__

module ActiveRecord::SerializeHash
  def self.included(base)
    base.extend ClassMethods
    base.alias_method_chain :reload, :serialize_hash
    base.before_update :update_serialize_hashes
  end

  def self.jsonize(data)
    return nil if data.nil?
    return data.to_json unless data.is_a?(Hash)

    "{" + data.to_a.
      map do |k,v| "#{k.to_json}:#{jsonize(v)}" end.
      sort.
      join(",") + 
    "}"
  end

  def self.unjsonize(data)
    r = data.blank? ? {} : JSON.parse(data)
    r = r.with_indifferent_access if r.respond_to?(:with_indifferent_access)
    r
  end
  
  module ClassMethods
    def serialize_hash_attributes
      @serialize_hash_attributes ||= Set.new
    end
    
    def serialize_hash(attr)
      serialize_hash_attributes << attr
      
      class_eval <<-RUBY
      def #{attr};     @#{attr} ||= ActiveRecord::SerializeHash.unjsonize read_attribute(:#{attr}); end
      def #{attr}=(d); write_attribute(:#{attr}, ActiveRecord::SerializeHash.jsonize(d)); @#{attr} = nil; 
      end
      RUBY
    end

    def hashed_attributes(*syms)
      serialize_hash :hashed_attributes

      syms.each do |sym|
        define_method(sym)        do hashed_attributes[sym] end
        define_method("#{sym}=")  do |val| hashed_attributes[sym] = val end
      end
    end
  end
  
  def reload_with_serialize_hash
    self.class.serialize_hash_attributes.each do |attr|
      instance_variable_set "@#{attr}", nil
    end
    reload_without_serialize_hash
  end

  def update_serialize_hashes
    self.class.serialize_hash_attributes.each do |attr|
      next unless val = instance_variable_get("@#{attr}")
      self.send "#{attr}=", val
    end
  end
end

class ActiveRecord::Base
  include ActiveRecord::SerializeHash
end

module ActiveRecord::SerializeHash::Etest
  def test_serialize_hash
    rb = RandomBase.create!
    
    assert_equal({}, rb.parameters)
    assert_nil(rb.parameters["test"])

    rb.parameters[:test] = "bla"
    assert_equal("bla", rb.parameters[:test])
    assert_equal("bla", rb.parameters["test"])
    
    rb.parameters["test"] = "lurk"

    assert_equal("lurk", rb.parameters[:test])
    assert_equal("lurk", rb.parameters["test"])

    rb.reload
    assert_nil(rb.parameters["test"])
    rb.parameters["test"] = "lurk"
    rb.save!

    rb.reload
    assert_equal("lurk", rb.parameters[:test])
    assert_equal("lurk", rb.parameters["test"])

    rb = RandomBase.find(rb.id)
    assert_equal("lurk", rb.parameters[:test])
    assert_equal("lurk", rb.parameters["test"])
  end

  def test_hashed_attributes
    rb = RandomBase.create!
    rb.ha1 = "ha1"
    assert_equal("ha1", rb.ha1)

    rb.reload
    assert_equal(nil, rb.ha1)
    rb.ha1 = "ha1"
    rb.save!
    rb.reload
    assert_equal("ha1", rb.ha1)
    
    rb = RandomBase.find(rb.id)
    assert_equal("ha1", rb.ha1)
  end
  
  def test_reload
    rb = RandomBase.create!
    rb.parameters[:test] = "bla"
    
    assert_equal("bla", rb.parameters[:test])
    rb.reload
    assert_nil(rb.parameters["test"])
  end
end
