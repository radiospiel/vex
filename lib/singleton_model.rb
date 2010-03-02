class SingletonModel < ActiveRecord::Base
  def self.find(*opts)
    # This somewhat stupid code is needed because AR doesn't yet support 
    # STI with namespaced names yet.
    #
    # See http://dev.rubyonrails.org/ticket/11575
    r = super
    return r if name != "SingletonModel"
    r.is_a?(Array) ? adjust_sti(r) : adjust_sti_obj(r)
  end
  
  def self.get
    find_by_name(self.name) || create!(:name => self.name)
  end

  private

  def self.adjust_sti_obj(o)
    return o unless o && o.name != "SingletonModel"
    o.name.constantize.find(o.id)
  end

  def self.adjust_sti(arr)
    arr.collect do |singleton| adjust_sti_obj(singleton) end
  end
end

module SingletonModel::Etest
  class A < SingletonModel; end
  class B < SingletonModel; end
  class B::C < SingletonModel; end
  
  def test_singleton
    assert_not_nil(A.get)
    assert_instance_of A, A.get
    assert_equal(A.get.id, A.get.id)

    assert_not_nil(B.get)
    assert_instance_of B, B.get
    assert_equal(B.get.id, B.get.id)
    assert_not_equal(A.get.id, B.get.id)
  end
  
  def test_sti
    assert_not_nil(B::C.get)
    assert_instance_of B::C, B::C.get
    assert_equal(B::C.get.id, B::C.get.id)
    assert_not_equal(A.get.id, B::C.get.id)
    assert_not_equal(B.get.id, B::C.get.id)
  end

  def test_all
    [ A, B, B::C ].each(&:get)
    
    class_names = SingletonModel.all.map do |s| s.class.name.sub(/SingletonModel::Etest::/, "") end.sort
    assert_equal(%w(A B B::C), class_names)
  end
end
