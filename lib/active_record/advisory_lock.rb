require 'active_record/connection_adapters/abstract_adapter'

module ActiveRecord::AdvisoryLock
  TIMEOUT=10
end

# --- load advisory lock extensions -----------------------------------

load 'active_record/advisory_lock/abstract_adapter.rb'
load 'active_record/advisory_lock/mysql_adapter.rb'
# load 'active_record/advisory_lock/postgresql_adapter.rb'
load 'active_record/advisory_lock/sqlite_adapter.rb'
