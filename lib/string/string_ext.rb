module StringExt
  def constantize?
    constantize
  rescue LoadError, NameError
  end
  
  def uri?
    !!(self =~ /^[a-z][a-z]+:/)
  end
  
  def unhtml
    return self if blank?
    s = Sanitize.clean(self)
    HTMLEntities.new.decode(s)
  end

  # truncate :length => 30, :omission => "…"
  def truncate(*args)
    opts = if args.length == 1 && args.first.is_a?(Hash)
      args.first
    else
      args.inject({}) do |hash, arg|
        key = case arg
        when Fixnum then :length
        when String then :omission
        end
      
        invalid_argument!(arg) if key.nil? || hash[key]
      
        hash.update key => arg
      end
    end
    
    _truncate(opts)
  end
  
  def _truncate(opts)
    opts = { :length => opts, :omission => "…" } unless opts.is_a?(Hash)
    opts.reverse_merge!(:length => 30, :omission => "…")
    
    l = opts[:length] - opts[:omission].mb_chars.length
    chars = mb_chars
    if chars.length > opts[:length] 
      (chars[0...l] + opts[:omission]).to_s
    else
      self
    end
  end

  def truncate!(opts = {})
    replace truncate(opts)
  end
  
  def word_wrap(line_len=100)
    lines = split("\n")
    lines.map { |line| StringExt.word_wrap(line, line_len) }.join("\n")
  end

  def self.word_wrap(line, line_len)
    r = []
    while line.length > line_len
      # find last space in the first line_len characters. Failing that we
      # take the *first* (sic!) space in the entire line.
      firstline = line[0..line_len]
      space_idx = firstline.rindex(/\s/) || line.index(/\s/, line_len)

      if !space_idx
        r << line
        line = ""
      else
        r << line[0...space_idx]
        line = line[space_idx+1..-1]
      end
    end

    r << line unless line.blank?
    r.join("\n")
  end
end

String.send :include, StringExt

module StringExt::Etest
  def test_unhtml
    assert_equal("", "".unhtml)
    assert_equal("hjghjg", "<p>hjghjg</p>".unhtml)
    assert_equal("&auml", "&auml".unhtml)
    assert_equal("ä", "&auml;".unhtml)
  end

  # truncate :length => 30, :omission => "..."
  def test_truncate
    assert_equal("", "".truncate)
    assert_equal("123456", "123456".truncate)
    assert_equal("123…", "1234567".truncate(:length => 6))
    assert_equal("123…", "1234567".truncate(6))
    assert_equal("12345~", "1234567".truncate(6, "~"))
  end

  def test_truncate!
    s = "1234567"

    assert_equal "123…", s.truncate(6)
    assert_equal "1234567", s

    assert_equal "123…", s.truncate!(6)
    assert_equal "123…", s
  end

  def test_word_wrap
    assert_equal "abcdef\nghijkl",  "abcdef ghijkl".word_wrap(8)
    assert_equal "abc def\nghijkl", "abc def ghijkl".word_wrap(8)
    assert_equal "abcdefghijkl",    "abcdefghijkl".word_wrap(8)
  end
  
  def test_uri
    assert_equal true, "http://".uri?
    assert_equal false, "//".uri?
    assert_equal false, "c:\\x\\y".uri?
  end

  def test_constantize
    assert_equal String, "String".constantize?
    assert_equal nil, "I::Dont::Know::This".constantize?
  end
end
