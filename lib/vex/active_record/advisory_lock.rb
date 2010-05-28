require "active_record/connection_adapters/abstract_adapter"

module ActiveRecord::AdvisoryLock
  TIMEOUT=10
end

#
# The concrete implementations are in the advisory_lock directory.
# They will be loaded by the init script, so we don't load them
# here again. 
# --- load advisory lock extensions -----------------------------------

# load "#{File.dirname(__FILE__)}/advisory_lock/mysql_adapter.rb"
# load "#{File.dirname(__FILE__)}/advisory_lock/postgresql_adapter.rb"
# load "#{File.dirname(__FILE__)}/advisory_lock/sqlite_adapter.rb"
