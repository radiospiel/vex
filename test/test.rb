#!/usr/bin/env ruby
DIRNAME = File.expand_path File.dirname(__FILE__)

Dir.chdir(DIRNAME)

RAILS_ENV="test"
RAILS_ROOT="#{DIRNAME}"

require 'rubygems'
require 'ruby-debug'

require 'active_record'
require 'active_resource'
require 'action_controller'

#if !defined?(Mpx)
#  require '../../mpx/init'
#end

RAILS_DEFAULT_LOGGER=Logger.new(STDERR)

require 'test/unit'
require DIRNAME + '/../init'
require 'mocha'

# SQLITE3_FILE = ":memory:" 
SQLITE3_FILE = "test.sqlite3"

File.unlink(SQLITE3_FILE) rescue nil
ActiveRecord::Base.logger = Logger.new("log/test.log")
ActiveRecord::Base.logger.level = Logger::DEBUG
ActiveRecord::Base.establish_connection(
	:adapter => "sqlite3",
  :database => SQLITE3_FILE
)

# -----------------------------------------------------------------------------------------------


Vex.add_path DIRNAME + '/lib'
Vex.add_path DIRNAME + '/cases'

db = ActiveRecord::Base.connection

STDERR.print "\nDefine test tables: "
Dir.glob("schema/*.rb").sort.each do |file|
  STDERR.print "#{File.basename_wo_ext(file)} "
  db.__send__ :eval, File.read(file)
end
STDERR.puts

# -- collect tests

STDERR.puts "\nLoad etests"

etests = []
rex = /^\s*module\s+(\S*\bEtest\b)/

dirs = [ "../lib", "../ext", "cases" ]
dirs.each do |dir|
  dir = "#{DIRNAME}/#{dir}"
  File.grep(rex, Dir.glob("#{dir}/**/*.rb")) do |_, _, matches|
    etests << matches[1]
  end
end

etests = etests.uniq.sort

puts "Running #{etests.inspect}"

# -- load tests

etests = etests.each do |etest|
  begin
    mod = etest.constantize
  rescue
    STDERR.puts("  #{etest}: cannot load test")
    STDERR.puts($!)
    next
  end
  
  tests = mod.instance_methods.select { |m| m =~ /^test_/ }

  next STDERR.puts("  #{etest}: Does not define any tests") if tests.empty?

  STDERR.puts("  #{etest}: w/#{tests.length} tests")

  klass = Class.new(Test::Unit::TestCase)
  klass.send :include, mod

  mod.const_set("TestCase", klass)
end.compact

STDERR.puts "\nRunning etests\n\n"
