module ActiveRecord::ConnectionAdapters
  class SQLiteAdapter < AbstractAdapter
    def locked(lock, opts = {}, &block)
      database = instance_variable_get("@config")[:database]
      return yield if database == ":memory:"

      File.locked("#{database}.#{lock}", &block)
    end
  end
end
