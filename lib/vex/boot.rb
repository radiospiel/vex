module Vex
  ROOT=File.expand_path "#{File.dirname(__FILE__)}/../vex"
  
  def self.version
    @version ||= File.read("#{ROOT}/../../VERSION")
  end

  #
  # load all modules from a specific directory.
  # This loads first all files in or under that directory, 
  # sorted alphabetically. Hint: use files __init__.rb
  # for stuff that must be loaded first.
  def self.load_directory(directory)
    (Dir.glob("#{ROOT}/#{directory}/**/*.rb") - [__FILE__]).sort.each do |file|
      load file
    end
  end
end

Vex.load_directory "../../config"
Vex.load_directory "boot"

module Vex::Etest
  def test_version
    assert_not_nil(Vex.version)
  end
end
