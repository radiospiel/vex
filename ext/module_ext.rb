class Module
  # tries to reload the source file for this module. THIS IS A DEVELOPMENT
  # helper, don't try to use it in production mode!
  #
  # Limitations:
  #
  # To reload a module with a name of "X::Y" we try to load (in that order) 
  # "x/y.rb", "x.rb"
  #
  def reload
    Module::Reloader.reload_file("#{to_s.underscore}.rb") || begin
      STDERR.puts("Cannot reload module #{self}")
      false
    end
  end

  module Reloader
    def self.reload_file(file)
      begin
        load(file) && file
      rescue MissingSourceFile
        nfile = file.gsub(/\/[^\/]+\.rb/, ".rb")
        nfile != file && reload_file(nfile)
      end
    end
  end

  # returns all objects that are instances of this module (or class)
  def instances
    r = []
    ObjectSpace.each_object do |obj|
      begin
        r << obj if obj.is_a?(klass)
      rescue NameError
      end
    end
    r
  end
end

module Module::UnknownTestModule; end

module Module::Etest

  def test_reload
    assert_equal("array/cross.rb", Array::Cross.reload)
    assert_equal("array/cross.rb", Array::Cross::Etest.reload)

    # cannot load "module/strange.rb"
    assert_equal(false, Module::UnknownTestModule.reload)
  end

  def test_instances
    return if LocalConf.fast_tests?

    return
    
    
    a, b = [ ], [ 1 ]
    instances = Array.instances.collect(&:object_id)
    
    assert instances.include?(a.object_id)
    assert instances.include?(b.object_id)
  end
end
