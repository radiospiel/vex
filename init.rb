#
# The initializer for the gem. Runs whenever the gem is loaded.
#
# DON'T CHANGE THIS FILE, CHANGE config/gem.rb INSTEAD!
#

gem_root = File.expand_path(File.dirname(__FILE__))
gem_name = File.basename gem_root

require "rubygems"

load "#{gem_root}/config/gem.rb"
load "#{gem_root}/config/dependencies.rb"
load "#{gem_root}/lib/#{gem_name}.rb"

dirs = Dir.glob("#{gem_root}/lib/*").sort.select do |dir|
  File.directory?(dir)
end.sort

dirs.each do |dir|
  if File.exists?("#{dir}/__init__.rb")
    STDERR.puts dir
    load("#{dir}/__init__.rb")
  else
    Dir.glob("#{dir}/*.rb").sort.each do |file|
      STDERR.puts file
      load file
    end
  end
end

Dir.glob("#{gem_root}/lib/*.rb").sort.each do |file|
  STDERR.puts file
  load file
end
