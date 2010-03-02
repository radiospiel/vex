def ArgumentError.message(default_text, *args)
  msg = args.first.is_a?(String) ? args.shift : default_text

  case args.length
  when 0 then msg
  when 1 then "#{msg}: #{args.first.inspect}"
  else        "#{msg}: #{args.inspect}"
  end
end

class InvalidArgument < ArgumentError
  def initialize(*args)
    super ArgumentError.message("Invalid argument", *args)
  end
end

def invalid_argument!(*args)
  raise InvalidArgument.new(*args)
end

class MissingOptions < ArgumentError
  def initialize(*args)
    super ArgumentError.message("Missing options", *args)
  end
end

def missing_options!(*args)
  raise MissingOptions.new(*args)
end

class MissingImplementation < ArgumentError
  def initialize(*args)
    super ArgumentError.message("Missing options", *args)
  end
end

class Module
  def not_implemented(*args)
    class_eval args.map { |arg| "def #{arg}(*args); not_implemented!; end\n" }.join
  end
end

class Object
  def not_implemented!
    raise MissingImplementation.new "#{self.class}##{caller_method_name}"
  end

  private
  
  def caller_method_name
    parse_caller(caller(2).first).last || "unknown"
  end

  def parse_caller(at)
    if /^(.+?):(\d+)(?::in `(.*)')?/ =~ at
      file = Regexp.last_match[1]
      line = Regexp.last_match[2].to_i
      method = Regexp.last_match[3]
      [file, line, method]
    end
  end
end

module Module::Etest
  class X
    not_implemented :a, :b
  end
  
  def test_missing
    assert_raise(MissingImplementation) { X.new.a }
    assert_raise(MissingImplementation) { X.new.a 1, 2 }
  end
end
