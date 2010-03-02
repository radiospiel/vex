if defined?(ActiveRecord)
  Dir.glob("#{File.dirname(__FILE__)}/*.rb").sort.each do |file|
    next if file == __FILE__ 
    load file
  end
  
  if defined?(ActiveRecord::ConnectionAdapters::MysqlAdapter)
    ActiveRecord::ConnectionAdapters::MysqlAdapter.send :include, ActiveRecord::MysqlBackup
  end
end