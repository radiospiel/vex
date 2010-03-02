#
# Initialize the gem

require "active_record"

if defined?(ActiveRecord)
  load "#{File.dirname(__FILE__)}/plugins/default_value_for/init.rb"
end
