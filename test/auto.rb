#
# set up AR

# require "rubygems"

require 'rubygems'
require 'sqlite3'
require 'active_record'

LOGFILE = "log/test.log"
SQLITE_FILE = ":memory:"

#
# -- set up active record for tests -----------------------------------
ACTIVE_RECORD = {
  :adapter => "sqlite3",
  :database => ":memory:"
}

ActiveRecord::Base.logger ||= Logger.new $STDERR

#
# setup connection
ActiveRecord::Base.establish_connection ACTIVE_RECORD


#
# start tests
VEX_TEST="active_record"
VEX_AUTO_TEST=true
load "#{File.dirname(__FILE__)}/test_helper.rb"
