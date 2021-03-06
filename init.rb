#
# The initializer for the gem. Runs whenever the gem is loaded.
#
# DON'T CHANGE THIS FILE, CHANGE config/gem.rb INSTEAD!
#

__END__

gem_root = File.expand_path(File.dirname(__FILE__))
gem_name = File.basename gem_root

require "rubygems"

load "#{gem_root}/config/gem.rb"
load "#{gem_root}/config/dependencies.rb"
load "#{gem_root}/lib/#{gem_name}.rb"

dirs = Dir.glob("#{gem_root}/lib/*").select do |dir|
  File.directory?(dir)
end.sort_by do |dir|
  dir.ends_with?("boot") ? "" : dir
end

dirs.each do |dir|
  if File.exists?("#{dir}/__init__.rb")
    load("#{dir}/__init__.rb")
  else
    Dir.glob("#{dir}/*.rb").sort.each do |file|
      load file
    end
  end
end

Dir.glob("#{gem_root}/lib/*.rb").sort.each do |file|
  load file
end
