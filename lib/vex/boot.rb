require "fileutils"

module Vex
  ROOT=File.expand_path "#{File.dirname(__FILE__)}/../vex"
  
  def self.version
    @version ||= File.read("#{ROOT}/../../VERSION").gsub(/\s+/, "")
  end

  #
  # load all modules from a specific directory.
  # This loads first all files in or under that directory, 
  # sorted alphabetically. Hint: use files __init__.rb
  # for stuff that must be loaded first.
  def self.load_directory(directory)
    # load plugins first
    plugin_dir = "#{ROOT}/#{directory}/plugins"
    Dir.glob("#{plugin_dir}/*").each do |file|
      load_plugin file if File.directory?(file)
    end
    
    (Dir.glob("#{ROOT}/#{directory}/**/*.rb") - [__FILE__]).sort.each do |file|
      next if file[0, plugin_dir.length] == plugin_dir
      load file
    end
  end

  def self.load_plugin(directory)
    $:.push(directory)
    init_rb = "#{directory}/init.rb"
    require(init_rb) if File.exists?(init_rb)
  end
end

Vex.load_directory "../../config"
Vex.load_directory "boot"

module Vex::Etest
  def test_version
    assert_not_nil(Vex.version)
  end
end if VEX_TEST == "boot"
