module ActiveRecord::LiteTable
  class ColumnTypeMismatch < RuntimeError; end
  
  class Validator
    attr :klass
    attr :options
    
    def initialize(klass, options)
      @klass = klass
      @options = options
    end

    def column(name, type, opts = {})
      klass.silence do
        if !existing_column = klass.columns_hash[name.to_s]
          index_opt = opts.delete :index
          klass.connection.add_column(klass.table_name, name, type, opts)
          klass.reset_column_information

          index(name, :unique => (index_opt == :unique)) if index_opt 
          return
        end

        return if existing_column.type == type

        raise ColumnTypeMismatch, 
          "Column type mismatch on #{klass}##{name}: is #{existing_column.type}, but should be #{type}"
      end
    end

    def timestamps(*cols)
      opts = cols.extract_options!
      cols = [ :created_at, :updated_at ] if cols.empty?

      index_opts = case index_opts = opts[:index]
      when Symbol then [ index_opts ]
      when Array  then index_opts
      when true   then [:created_at, :updated_at]
      else []
      end
      
      index_opts &= cols
      
      cols.each do |col|
        column(col, :datetime, :index => index_opts.include?(col))
      end
    end

    SHORTCUTS=%w(primary_key string text integer float
      decimal datetime timestamp time date binary boolean)

    SHORTCUTS.map(&:to_sym).each do |shortcut| 
      define_method(shortcut) do |name, *opts|
        column(name, shortcut, *opts)
      end
    end
    
    def index(column_name, options={})
      begin
        klass.silence do
          klass.connection.add_index klass.table_name, column_name, options
        end
      rescue
        # TODO: It would be *great* to have a unique exception type here!
        # But even in this case we have to check the options for identity!
        case $!
        when ActiveRecord::StatementInvalid, SQLite3::SQLException
          return if $!.to_s =~ /Duplicate key name/       # for MySQL
          return if $!.to_s =~ /index .* already exists/  # for Sqlite3
          return if $!.to_s =~ /relation .* already exists/  # for Postgresql
        end
        
        raise
      end
    end
  end
  
  def lite_table(opts={}, &block)
    # if table does not exist: create it, according to specs.
    connection.tables.include?(table_name) || 
      connection.create_table(table_name, opts) {}

    # run validator: This creates missing columns and indices. It never drops
    # any data from the database, though. 
    validator = Validator.new(self, opts)
    Proc.new.bind(validator).call
  end
  
  def remove_columns(*columns)
    connection.remove_columns table_name, *columns
    reset_column_information
  end
end

ActiveRecord::Base.extend ActiveRecord::LiteTable

module ActiveRecord::LiteTable::Etest
  class TestLiteModel < ActiveRecord::Base
  end
  
  def test_lite_table
    TestLiteModel.lite_table do
    end
    
    assert_equal(%w(id), TestLiteModel.column_names.sort)

    # we can use this class.
    m = TestLiteModel.create!
    assert_not_nil(m)
    assert_not_nil(m.id)
    
    # we cannot change a column type
    assert_raise(ActiveRecord::LiteTable::ColumnTypeMismatch) {  
      TestLiteModel.lite_table do
        string :id
      end
    }

    # we can add additional columns
    TestLiteModel.lite_table do
      string :name
    end
    
    # we can use this class.
    m = TestLiteModel.create! :name => "name"
    assert_not_nil(m)
    assert_not_nil(m.id)
    assert_equal("name", m.name)

    # we can add indices: we test index creation by creating a unique index
    # on a column that contains two identical entries.
    m = TestLiteModel.create! :name => "name"

    assert_raises(ActiveRecord::StatementInvalid) {  
      TestLiteModel.lite_table do
        index :name, :unique => true
      end
    }

    TestLiteModel.lite_table do
      index :name
    end
  end
end
