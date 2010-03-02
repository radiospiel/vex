#
# Initialize the gem

if defined?(ActiveRecord)
  load "#{File.dirname(file)}/plugins/default_value_for/init.rb"
end
