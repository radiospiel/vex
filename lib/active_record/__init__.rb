if defined?(ActiveRecord)
  
  class ActiveRecord::Base
    extend Conditions
    extend FindByExtension
    extend Each
    extend LiteTable
    include Resolver
    include RandomID
    include AssociatedHash
    include SerializeHash
    include ToHtml
    include BelongsToMany
    extend MassLoad::ClassMethods
  end

  if defined?(ActiveRecord::ConnectionAdapters::MysqlAdapter)
    ActiveRecord::ConnectionAdapters::MysqlAdapter.send :include, ActiveRecord::MysqlBackup
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

  load "active_record/advisory_lock.rb"

  ActiveRecord::ValidationErrorExt.init
end