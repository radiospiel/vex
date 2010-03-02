#
# -- set up active record for tests -----------------------------------
ACTIVE_RECORD = {
  :adapter => "sqlite3",
  :database => ":memory:"
}

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.logger ||= if defined?(RAILS_DEFAULT_LOGGER)
    RAILS_DEFAULT_LOGGER
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


Dir.glob(File.dirname(__FILE__) + "/schema/*.rb").sort.each do |file|
  ActiveRecord::Base.connection.send :eval, File.read(file)
  STDERR.puts file
end
