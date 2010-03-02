task :default => :test

task :test do
	sh "cd test; ruby test.rb"
end

task :rcov do
  sh "cd test; rcov -T -o ../coverage -x ruby/.*/gems -x ^initializers/ -x ^test.rb$ test.rb"
end

task :rdoc do
  sh "rdoc -o doc/rdoc"
end

task :rebuild => :test do
  sh "rake -f tasks/echoe.rake rebuild"
end

SKIP_ECHOE=true

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each do |ext| 
  load ext 
end
