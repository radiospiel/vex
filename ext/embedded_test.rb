if RAILS_ENV == "production" 
  class EmbeddedTest; end
else

require "test/unit"

#
# Embedded test cases
class EmbeddedTest < Test::Unit::TestCase
  include ComparisonAssertions
  
  #
  # Note: the rake testloader calls this method with 0 parameters!!!
  def self.suite(*tests)
    mod = tests.shift
    
    #
    # This is for "rake test" integration
    return Test::Unit::TestSuite.new("EmbeddedTest") if !mod
    
    if tests.empty?
      tests = mod.instance_methods.sort.select {|m| m =~ /^test/} 
      tests.reject! { |m| mod.instance_method(m).arity != 0 }
      
      raise ArgumentError, "#{mod}: No tests defined" if tests.empty?
    else
      rejecting = tests.select { |m|
        method = mod.instance_method(m.to_sym) rescue nil
        method ||= mod.instance_method(m.to_s) rescue nil
        
        !method || method.arity != 0 
      }
      
      raise ArgumentError, "#{mod}: Rejecting tests #{rejecting.join(", ")}" unless rejecting.empty?
    end
    
    suite = Test::Unit::TestSuite.new(mod.name)
     
    tests.each do |test| suite << new(test, mod) end

    return suite
  end

  def initialize(method, mod)
    # first extend the object with the module, and then convert it into 
    # a real TestCase object. This actually allows for the invalid_test
    # check (Note: our tests are already valid, or are requested by the 
    # user manually) 
    self.extend mod
    super(method)
  end

  # runs a test. Returns true or false
  def self.run_wo_transaction(mod, *tests)
    mod = load_test_for(mod) unless mod.name.to_s.ends_with?("::Etest")
    
    require 'test/unit/ui/console/testrunner'
    runner = Test::Unit::UI::Console::TestRunner
    r = runner.run(self.suite(mod, *tests), Test::Unit::UI::NORMAL) # PROGRESS_ONLY
    r.failure_count + r.error_count == 0
  end


  class Rollback < RuntimeError; end
  
  # runs a test. Returns true or false
  def self.run(mod, *tests)
    self.running = true

    begin
      ActiveRecord::Base.transaction do 
        run_wo_transaction(mod, *tests)
        raise Rollback
      end
    rescue Rollback
    end

    self.running = nil
  end

  def self.running=(r); @running = r; end
  def self.running?; @running; end
  
  private
  
  def self.load_module(name)
    mod = name.constantize rescue nil
    raise ArgumentError, "Missing module #{name}" unless mod && mod.name == name && mod.is_a?(Module)
    mod
  end
    
  def self.load_test_for(mod)
    load_module("#{mod}::Etest")
  end

  def self.load_from_directories(*dirs)
    Grep.load_from_directories *dirs
  end
end

end
