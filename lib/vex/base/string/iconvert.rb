class String
  module Iconvert
    def self.char_guess
      @char_guess ||= begin
        require 'charguess' # not necessary if input encoding is known
        CharGuess
      rescue LoadError
        dlog "Please install the charguess gem as pointed out here: http://radiospiel.org/0x2a-smooth-charguess-install"
        FakeCharGuess
      end
    end

    def self.encoding(enc)
      enc = enc.to_s.upcase
      ALIASES[enc] || enc
    end

    def self.convert(s, ie, oe)
      invalid_argument! oe unless oe.is_a?(Symbol) or oe.is_a?(String)

      ie ||= char_guess.guess(s)
      return s.dup if ie.nil?
      
      ie, oe = encoding(ie), encoding(oe)
      return s.dup if ie == oe

      #
      # Note: Iconv is part of the ruby std lib.
      require 'iconv'
      Iconv.new(oe, ie).iconv(s)
    end

    ALIASES = {
      "UTF8" => "UTF-8"
    }

    def self.invalid_encoding(*encodings)
      # Note: "US-ASCII" is always a valid encoding.
      valid = "US-ASCII"

      ex = nil
      invalid_encodings = ([ valid ] + encodings).reject do |enc|
        begin
          Iconv.new(valid, encoding(enc))
        rescue Iconv::InvalidEncoding
          ex = $!
          nil
        end
      end
      
      return if invalid_encodings.empty?
      
      def ex.to_s
        @msg
      end

      ex.instance_variable_set "@msg", 
        "Invalid encoding(s): #{invalid_encodings.join(", ")}; check 'iconv -l' for supported encodings"
    
      raise ex
    end
  end

  def iconv(encoding)
    if encoding.is_a?(Hash)
      invalid_argument! encoding unless encoding.length == 1
      ie, oe = *encoding.first
    else
      ie, oe = nil, encoding
    end

    Iconvert.convert self, ie, oe
  rescue Iconv::InvalidEncoding
    Iconvert.invalid_encoding ie, oe
  end
end

module String::Etest
  def test_iconvert
    assert_equal "s", "s".iconv(:utf8) 

    assert_equal "s", "s".iconv("US-ASCII" => "UTF8")
    #
    # convert from "latin1" to "utf8"
    assert_equal "s", "s".iconv(:latin1 => "UTF8")

    assert_raises(Iconv::InvalidEncoding) do
      assert_equal "s", "s".iconv(:utf9 => :utf12) 
    end

    assert_raises(Iconv::InvalidEncoding) do
      assert_equal "s", "s".iconv(:ascii => :utf12) 
    end
  end
end if VEX_TEST == "base"
