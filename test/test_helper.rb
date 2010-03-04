DIRNAME = File.expand_path File.dirname(__FILE__)
Dir.chdir(DIRNAME)

require "rubygems"
require "etest"

APP_ROOT = DIRNAME

# require "active_record"
# 
# require "#{DIRNAME}/initializers/fake_rails.rb"

#
# initialize the gem and the test runner
$:.push "#{DIRNAME}/../lib"

require "vex/#{VEX_TEST}"


# ---------------------------------------------------------------------

require 'mocha'
require 'ruby-debug'

begin
  require 'minitest-rg'
rescue MissingSourceFile
  STDERR.puts "'gem install minitest-rg' gives you redgreen minitests"
  require 'minitest/unit'
end

#
# run tests
dlog "etest #{::Etest::VERSION}"

Etest.autorun if defined?(::Etest)
# MiniTest::Unit.autorun
