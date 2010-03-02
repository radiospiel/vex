module ActiveRecord::ConnectionAdapters
  class MysqlAdapter < AbstractAdapter
    TIMEOUT=5
    
    def locked(lock, opts = {})
      lock = "#{current_database}.rails.#{lock}"

      begin
        execute "SELECT GET_LOCK(#{quote(lock)},#{opts[:timeout] || TIMEOUT})"
        yield
      ensure
        execute "SELECT RELEASE_LOCK(#{quote(lock)})"
      end
    end
  end
end
