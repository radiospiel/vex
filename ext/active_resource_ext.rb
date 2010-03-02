class ActiveResource::Base
  class << self # Class methods
    # A convenience wrapper for <tt>find(:first, *args)</tt>. You can pass in all the
    # same arguments to this method as you can to <tt>find(:first)</tt>.
    def first(*args)
      find(:first, *args)
    end

    # A convenience wrapper for <tt>find(:last, *args)</tt>. You can pass in all the
    # same arguments to this method as you can to <tt>find(:last)</tt>.
    def last(*args)
      find(:last, *args)
    end

    # This is an alias for find(:all).  You can pass in all the same arguments to this method as you can
    # to find(:all)
    def all(*args)
      find(:all, *args)
    end
  end
  
  def save!
    true if save_without_validation # this raises ActiveResource::ResourceInvalid if the resource could not be saved
  end

  private
  
  def _update_attributes(attrs)
    attrs.each do |k,v|
      self.__send__ "#{k}=", v
    end
  end
  
  public
  
  def update_attributes(attrs)
    _update_attributes(attrs)
    save
  end

  def update_attributes!(attrs)
    _update_attributes(attrs)
    save!
  end
end

# NOTE: These tests don't do much! They check that the correct
# functions are called in the ARes implementation - BUT THAT IS IT ALREADY!
module ActiveResource::Etest
  def test_first
    ActiveResource::Base.expects(:find).with(:first, {})
    ActiveResource::Base.first({})
  end

  def test_last
    ActiveResource::Base.expects(:find).with(:last, {})
    ActiveResource::Base.last({})
  end

  def test_all
    ActiveResource::Base.expects(:find).with(:all, {})
    ActiveResource::Base.all({})
  end

  def test_save!
    ActiveResource::Base.any_instance.expects(:save_without_validation).returns(true)
    ActiveResource::Base.new.save!
  end

  def test_update_attributes
    ActiveResource::Base.any_instance.expects("a=").with("aa")
    ActiveResource::Base.any_instance.expects("b=").with("bb")
    ActiveResource::Base.any_instance.expects("save")
    
    ActiveResource::Base.new.update_attributes :a => "aa", :b => "bb"
  end

  def test_update_attributes!
    ActiveResource::Base.any_instance.expects("a=").with("aa")
    ActiveResource::Base.any_instance.expects("b=").with("bb")
    ActiveResource::Base.any_instance.expects("save!")
    
    ActiveResource::Base.new.update_attributes! :a => "aa", :b => "bb"
  end
end
