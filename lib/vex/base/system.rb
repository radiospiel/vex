module System
  class ProcessFailed < RuntimeError; 
    attr_reader :cmd, :exitstatus

    def initialize(cmd)
      @cmd, @exitstatus = cmd, $?.exitstatus
    end
    
    def to_s
      "exit code: #{exitstatus}"
    end
    
  end

  def self.sys!(*args)
    cmd = args.join(" ")
    
    benchmark "**** Running #{cmd}" do
      next true if system(cmd)
      raise ProcessFailed, cmd 
    end
  end

  def self.sys(*args)
    sys!(*args)
  rescue ProcessFailed
    App.logger.warn "#{args.join(" ")}: #{$!}"
    false
  end
  
  def self.uname
    @uname ||= `uname`.chomp
  end

  def self.name
    case uname
    when "Darwin" then :osx
    when "Linux" then :linux
    else raise "Unsupported OS uname #{uname}"
    end
  end

  def self.linux?
    uname == "Linux"
  end
  
  def self.which(binary)
    r = `which #{binary}`.chomp
    r.blank? ? nil : r
  end
  
  def self.which!(binary)
    which(binary) || abort("Missing binary #{binary}")
  end
end

module Hash::Etest
  def test_system
    assert_equal true, System.sys("true")
    assert_equal false, System.sys("false")
    assert_equal false, System.sys("command_not_existing")
  end

  def test_system!
    assert_nothing_raised { System.sys!("true") }
    assert_raise(System::ProcessFailed) { System.sys!("false") }
    assert_raise(System::ProcessFailed) { System.sys!("command_not_existing") }
  end

  def test_which
    assert_equal "/bin/ls", System.which("ls")
    assert_equal nil, System.which("lslslslslslslslslslslslslslsls")
  end

  def test_which!
    assert_equal "/bin/ls", System.which!("ls")
    assert_raise(SystemExit) {  
      System.which!("lslslslslslslslslslslslslslsls")
    }
  end
end if VEX_TEST == "base"

