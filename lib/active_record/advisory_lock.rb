require "active_record/connection_adapters/abstract_adapter"

module ActiveRecord::AdvisoryLock
  TIMEOUT=10
end

# --- load advisory lock extensions -----------------------------------

load "#{File.dirname(__FILE__)}/advisory_lock/mysql_adapter.rb"
# load "#{File.dirname(__FILE__)}/advisory_lock/postgresql_adapter.rb"
load "#{File.dirname(__FILE__)}/advisory_lock/sqlite_adapter.rb"
