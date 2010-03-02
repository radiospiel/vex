require "default_value_for"

__END__

if !defined?(RAILS_ENV)
  STDERR.puts "Setting up dummy rails environment"

  RAILS_ENV="test"
  RAILS_ROOT="."

  require 'activerecord'
  require 'active_support'
end

require "#{File.dirname(__FILE__)}/lib/vex.rb"
require "sanitize"

#
# load foreign plugins first.
Dir.glob("#{File.dirname(__FILE__)}/plugins/*").sort.each do |plugin|
  # STDERR.puts "Loading #{plugin}"

  Vex.add_path("#{plugin}/lib")
  require "#{plugin}/init.rb" if File.file?("#{plugin}/init.rb")
end


#
# add library path
Vex.add_path("#{File.dirname(__FILE__)}/lib")

#
# run initializers

STDERR.print "Initializing vex: "

#
# load platform fixes
Vex.require_subdir "#{File.dirname(__FILE__)}/fixes"

#
# load core extensions
Vex.require_subdir "#{File.dirname(__FILE__)}/ext"

#
# run initializers
Vex.require_subdir "#{File.dirname(__FILE__)}/initializers"
STDERR.puts

#reloads the environment
def reload!
  STDERR.puts "Reloading..."
  dispatcher = ActionController::Dispatcher.new($stdout)
  dispatcher.cleanup_application
  dispatcher.reload_application

  # The folloowing line actually reloads the Ext module,
  # which results in running the .load! line below. 
  Vex
  true
end

STDERR.puts "\n"
