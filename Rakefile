task :default => :"test:all"
task :test => :"test:all"
task :rcov => :"rcov:all"

namespace :test do
  task :boot do
    sh "ruby test/boot.rb"
  end

  task :base do
    sh "ruby test/base.rb"
  end

  task :ar do
    sh "ruby test/ar.rb"
  end

  task :auto do
    sh "ruby test/auto.rb"
  end

  task :all => %w(boot base ar)
end

namespace :rcov do
  task :boot do
    sh "rcov -T -o coverage/boot -x ruby/.*/gems test/boot.rb"
  end

  task :base do
    sh "rcov -T -o coverage/base -x /vex/boot -x ruby/.*/gems test/base.rb"
  end

  task :ar do
    sh "rcov -T -o coverage/ar -x /vex/boot/ -x /plugins/ -x /vex/base/ -x ruby/.*/gems test/ar.rb"
  end

  task :all => %w(boot base)
end

task :rebuild => :test do
  sh "rake -f tasks/echoe.rake rebuild"
end

task :manifest do
  sh "rake -f tasks/echoe.rake manifest"
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each do |ext| 
  load ext 
end

load "#{File.dirname(__FILE__)}/vex/gem.rake"
