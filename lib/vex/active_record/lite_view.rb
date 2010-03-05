# TODO: LiteViews do not or not always support type information. Therefore values
# might be returned as strings, when in fact they are numbers. This behaviour is
# heavily database dependant.
#
# It would be great to fix it.

class ActiveRecord::LiteView < ActiveRecord::Base
  lite_table do
    string :name
    text :sql

    index :name
  end
  
  after_save do |rec|
    locked(rec, &:create_view)
  end

  after_destroy do |rec|
    locked(rec, &:drop_view)
  end

  private
  
  def self.view_name(v)
    case v
    when Hash   then "#{v[:klass].table_name}__#{v[:view]}"
    when self   then v.name
    end
  end

  def drop_view
    ActiveRecord::Base.connection.execute("DROP VIEW #{name}") rescue nil
  end
  
  def create_view
    raise ArgumentError, "Missing SQL code" unless sql

    drop_view
    ActiveRecord::Base.connection.execute("CREATE VIEW #{name} AS #{sql}")
  end

  public
    
  def self.drop_view(klass, view)
    destroy_all :name => view_name(:klass => klass, :view => view)
  end

  def self.make(klass, view, sql)
    name = view_name(:klass => klass, :view => view)
    
    view = find_first(:name => name, :sql => sql)
    view ||= locked(name) do
      find_first(:name => name, :sql => sql) || create!(:name => name, :sql => sql)
    end

    # create a view class and return its name
    view_klass = Class.new(ActiveRecord::Base)
    view_klass.set_table_name name

    klass_name = "LV_#{name.camelize}"
    klass.send(:remove_const, klass_name) if klass.const_defined?(klass_name)
    klass.const_set(klass_name, view_klass)

    klass_name
  end
  
  private

  def self.find_first(conditions, opts = {})
    find :first, { :conditions => conditions }.update(opts)
  end
  
  def self.locked(lock)
    name = lock.is_a?(self) ? lock.name : lock
    
    ActiveRecord::Base.connection.locked("LiteView.make.#{name}") do
      yield lock
    end
  end
end

class ActiveRecord::Base
  def self.drop_view(view)
    ActiveRecord::LiteView.drop_view(self, view)
  end

  def self.has_view(view, sql)
    has_one view, :class_name => ActiveRecord::LiteView.make(self, view, sql)

    define_method "#{view}_reset" do 
      instance_variable_set "@#{view}", nil
    end
  end
end

#
# This is a fix to rails_sql_views' Mysql schema dumper
if defined?(ActiveRecord::ConnectionAdapters::MysqlAdapter)

class ActiveRecord::ConnectionAdapters::MysqlAdapter
  private
  
  def convert_statement(s)
    s.gsub(/.* AS (\(?select)/i, '\1')
  end
end

end

module ActiveRecord::LiteView::Etest
  class Holder < ActiveRecord::Base
    lite_table do
    end
  end
  
  def test_lite_view
    db = ActiveRecord::Base.connection

    Holder.create!
    Holder.create!
    Holder.create!

    assert_equal(3, Holder.count)
    
    # -- create a view
    Holder.has_view :view_dummy, "SELECT id AS holder_id, 1 AS count_all FROM holders"
    assert_equal("1", Holder.first.view_dummy.count_all)

    # -- doesnt recreate identical view
    # TODO: Check that an identical view won't be recreated
    # Holder.has_view :view_dummy, "SELECT id AS holder_id, 1 AS count_all FROM holders"
    
    assert_equal("1", Holder.first.view_dummy.count_all)

    # -- create a slightly different view
    Holder.has_view :view_dummy, "SELECT id AS holder_id, 2 AS count_all FROM holders"
    assert_equal("2", Holder.first.view_dummy.count_all)
  end
end
