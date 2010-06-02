module ActiveRecord::FindByExtension
  def find_all_by(args, opts = nil)
    return find(:all, :conditions => args) if opts.nil?

    with_scope(:find => opts) do find_all_by(args) end
  end

  def find_by(args, opts = nil)
    return find(:first, :conditions => args) if opts.nil?

    with_scope(:find => opts) do find_by(args) end
  end

  def find_by!(args, opts = nil)
    find_by(args, opts) || 
      raise(ActiveRecord::RecordNotFound, "Couldn't find #{self} with #{args.inspect}")
  end


  def create_by!(args, opts, &block)
    args = opts.update(args) if opts
    obj = new args
    if block_given?
      yield(obj)
    end
    obj.save!
    obj
  end
  
  def find_or_create_by(args, opts = nil, &block)
    find(:first, :conditions => args) || create_by!(args, opts, &block)
  end

  def find_or_create_all_by(args, opts = nil, &block)
    requested = args.cross

    models = find_all_by(args)
    return models if requested.length == models.length

    # TODO: Check locking
    connection.locked("#{self.name}#create") do
      models = find_all_by(args)
      return models if requested.length == models.length

      keys = args.keys
      missing = requested - models.map do |model| 
        args.keys.inject({}) do |hash, key| hash.update key => model.send(key) end
      end

      # TODO: Potential mass insert, when no block given
      missing.each do |data|
        models << create_by!(data, opts, &block)
      end
    end
    
    models
  end
end

class ActiveRecord::Base
  extend ActiveRecord::FindByExtension
end

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
  
  def test_find_all_by
    assert_equal(3, Data.find_all_by(:name => "name").length)
    assert_equal(3, Data.find_all_by(:name => [ "name" ]).length)
    assert_raise(ActiveRecord::StatementInvalid) {
      assert_equal(3, Data.find_all_by(:unknown => [ "name" ]).length)
    }

    assert_equal(2, Data.find_all_by(:name => [ "name" ], :age => [1, 2, 3]).length)
    assert_equal(2, Data.find_all_by({:name => [ "name" ]}, :conditions => { :age => [1, 2, 3]}).length)
  end

  def test_find_by
    assert_equal("name", Data.find_by(:name => "name").name)
    assert_equal(nil, Data.find_by(:name => "namex"))
  end

  def test_find_by!
    assert_equal("name", Data.find_by!(:name => "name").name)
    assert_raise(ActiveRecord::RecordNotFound) do
      Data.find_by!(:name => "namex")
    end
  end
end
