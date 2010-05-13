# --- an argument parser
class Argv < Hash
  def method_missing(sym, *args, &block)
    return fetch(sym) if args.empty? && !block_given? && key?(sym)
    super
  end
  
  class ArrayX < Array
    def shift(msg = nil)
      super() || raise(msg || "Cannot fetch from empty array")
    end
  end
  
  attr_reader :files
  
  def initialize(argv)
    @files = ArrayX.new
    argv = argv.dup
    while arg = argv.shift do
      if !(option = option?(arg))
        files.push(arg)
      elsif arg =~ /^--no-/
        set option, false
      elsif argv.first.nil? || option?(argv.first)
        set option, true
      else
        set option, argv.shift
      end
    end
  end

  private
  
  def set(key, value)
    unless value == true || value == false || !key?(key)
      unless (existing = fetch(key)).is_a?(Array)
        existing = [ existing ]
      end
      value = existing.push(value)
    end
    
    update key => value
  end
  
  def option?(arg)
    if arg.nil?
      false
    elsif (arg =~ /^--no-(.+)/) || (arg =~ /^--(.+)/)
      $1.to_sym
    else
      false
    end
  end
end

module Argv::Etest
  def test_argv
    args = Argv.new(%w(test))
    assert_equal [ "test" ], args.files

    args = Argv.new(%w(test1 test2 --no-xy))
    assert_equal [ "test1", "test2" ], args.files
    assert_equal false, args[:xy]
    assert_nil args[:bla]

    assert_equal false, args.xy
    assert_raises(NoMethodError) { args.bla }
  end
end

module App
  def self.argv
    @argv ||= Argv.new ARGV
  end
end
