class CreateRequestLog < ActiveRecord::Migration
  TABLE_NAME = ImprovedLogging::TABLE_NAME
  
  def self.up
    create_table TABLE_NAME, :force => true do |t|
      t.integer :user_id              # account ID
      t.string :ip                    # remote IP
      t.integer :xhr                  # yes/no
      t.string :method                # get/post etc.
      t.string :protocol              # http:/https:
      t.string :host                  # host
      t.string :path                  # path
      t.string :query                 # query param
      t.string :action                # controller + action
      t.string :status                # result status
      t.integer :msecs                # time needed 
      t.integer :queries              # of SQL queries needed
      t.integer :sql_select           # of SQL queries needed
      t.integer :sql_update           # of SQL queries needed
      t.integer :sql_insert           # of SQL queries needed
      t.integer :sql_delete           # of SQL queries needed
    end
  end

  def self.down
    drop_table(TABLE_NAME) rescue nil
  end
end
