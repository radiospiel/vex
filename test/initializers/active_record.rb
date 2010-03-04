
Dir.glob(File.dirname(__FILE__) + "/schema/*.rb").sort.each do |file|
  ActiveRecord::Base.connection.send :eval, File.read(file)
  STDERR.puts file
end
