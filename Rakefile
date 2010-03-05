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
    sh "rcov -T -o coverage/base -x /vex/boot/ -x ruby/.*/gems test/base.rb"
  end

  task :ar do
    sh "rcov -T -o coverage/ar -x /vex/boot/ -x /plugins/ -x /vex/base/ -x ruby/.*/gems test/ar.rb"
  end

  task :all => %w(boot base)
end

__END__

task :rcov do
  sh "cd test; rcov -T -o ../coverage -x ruby/.*/gems -x ^initializers/ -x config/plugins/ -x ^test.rb$ test.rb"
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
