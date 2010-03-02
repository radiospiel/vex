task :default => :test

task :test do
	sh "ruby test/test.rb"
end

task :rcov do
  sh "cd test; rcov -o coverage -i /vex/ -x /vex/test/ -x ^lib/ -x /gems/ -x ^test.rb$ --html  -T test.rb"
end
