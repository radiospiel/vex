#
# set up fake rails

require "active_record"

LOGFILE = "log/test.log"
SQLITE_FILE = ":memory:"

#
# -- set up fake rails ------------------------------------------------

RAILS_ENV="test"
RAILS_ROOT="#{DIRNAME}"

if !defined?(App.logger)
  FileUtils.mkdir_p File.dirname(LOGFILE)
  App.logger = Logger.new(LOGFILE)
  App.logger.level = Logger::DEBUG
end

#
# -- set up active record for tests -----------------------------------
ACTIVE_RECORD = {
  :adapter => "sqlite3",
  :database => ":memory:"
}

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.logger ||= if defined?(App.logger)
    App.logger
  else
    Logger.new $STDERR
  end

  #
  # setup connection
  begin
    ActiveRecord::Base.connection
  rescue ActiveRecord::ConnectionNotEstablished
    ActiveRecord::Base.establish_connection ACTIVE_RECORD
  end
end

