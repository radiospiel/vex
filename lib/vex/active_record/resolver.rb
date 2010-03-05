module ActiveRecord::Resolver
  #
  # resolves an object.
  def resolve(obj)
    case obj
    when self   then obj
    when String then self.find(Integer(obj))
    when Array  then obj.map { |o| resolve(o) }
    else        self.find(obj)
    end
  end
end

ActiveRecord::Base.extend ActiveRecord::Resolver

module ActiveRecord::FindByExtension::Etest
  class Data < ActiveRecord::Base
  end

  def setup
    Data.lite_table do
      string :name
      string :age
    end

    Data.create! :name => "name", :age => 2
    Data.create! :name => "name", :age => 3
    Data.create! :name => "name", :age => 4
    Data.create! :name => "name2", :age => 2
    Data.create! :name => "name2", :age => 3
    Data.create! :name => "name2", :age => 4

    assert_equal(6, Data.count)
  end
  
  def teardown
    Data.destroy_all
  end
  
  def test_resolve
    data2 = Data.find_by :name => "name", :age => 2
    data3 = Data.find_by :name => "name", :age => 3

    assert_equal data2, Data.resolve(data2)
    assert_equal data2, Data.resolve(data2.id)
    assert_equal data2, Data.resolve(data2.id.to_s)
    assert_equal [ data2, data3 ].sort_by(&:id), Data.resolve([data2.id, data3.id]).sort_by(&:id)
  end
end
