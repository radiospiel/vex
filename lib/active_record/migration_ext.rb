module ActiveRecord::MigrationExt
  def self.join_table_name(table1, table2)
    [ table1, table2 ].map { |t| t.to_s.pluralize }.sort.join("_")
  end

  def self.join_table_columns(table1, table2)
    [ table1, table2 ].map { |t| "#{t.to_s.singularize}_id" }.sort
  end
  
  def self.included(klass)
    klass.extend ClassMethods
  end
  
  module ClassMethods
    def create_join_table(t1, t2, opts = {})
      ext = ActiveRecord::MigrationExt

      opts = ({ :id => false }).update(opts)
      
      table_name = ext.join_table_name(t1, t2)

      create_table table_name, opts do |t|
        ext.join_table_columns(t1, t2).each do |col|
          t.integer col
        end

        t.timestamps
      end

      ext.join_table_columns(t1, t2).each do |col|
        add_index table_name, col
      end

      add_index table_name, ext.join_table_columns(t1, t2), :unique => true
    
      table_name
    end

    def drop_join_table(t1, t2)
      ext = ActiveRecord::MigrationExt
      drop_table ext.join_table_name(t1, t2)
    end
  end
end 

module ActiveRecord::MigrationExt::Etest
  def test_migration
    old = ActiveRecord::Migration.verbose
    ActiveRecord::Migration.verbose = false

    assert_equal(ActiveRecord::MigrationExt.join_table_name("user", "feed"), "feeds_users")
    
    # TODO: Please mock this!
    ActiveRecord::Migration.create_join_table "user", "feed"
    assert ActiveRecord::Base.connection.tables.include?("feeds_users")
    ActiveRecord::Migration.drop_join_table "user", "feed"

    ActiveRecord::Migration.verbose = old
  end
end
