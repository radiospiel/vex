class String
  module FakeCharGuess
    def self.guess(s)
      nil
    end
  end
  
  def self.char_guess
    @char_guess ||= begin
      require 'charguess' # not necessary if input encoding is known
      CharGuess
    rescue LoadError
      STDERR.puts "Please install the charguess gem as pointed out here: http://radiospiel.org/0x2a-smooth-charguess-install"
      FakeCharGuess
    end
  end

  def self.load_iconv
    @load_iconv ||= begin
      require 'iconv'
      Iconv
    end
  end

  def iconv(output_encoding, input_encoding=nil)
    input_encoding ||= String.char_guess.guess(self)
    return self.dup if input_encoding.nil? || input_encoding == output_encoding
    
    String.load_iconv.new(output_encoding.to_s, input_encoding.to_s).iconv(self)
  end
end

module String::Etest
  def test_iconvert
    assert "s".iconv("utf8") 
  end
end if VEX_TEST == "base"
