require "cgi"

class CGI
  def self.url_for(*args)
    opts = case args.last
    when Array, Hash then args.pop
    else                  {}
    end
    
    url_base = args.map do |arg|
      arg.gsub(/(^\/)|(\/$)/, "")
    end.join("/")
    
    return url_base if opts.empty?

    url_base += url_base.index("?") ? "&" : "?"

    url_base + opts.map do |k,v|
      p = escape(k.to_s)
      p += "=" + escape(v.to_s) if v
      p
    end.join("&")
  end
end

module CGI::Etest
  def test_url_for
    assert_equal "http://ix.de", CGI.url_for("http://ix.de")
    assert_equal "http://ix.de?a", CGI.url_for("http://ix.de", :a => nil)
    assert_equal "http://ix.de?a", CGI.url_for("http://ix.de", [ :a ])
    assert_equal "http://ix.de?a=1", CGI.url_for("http://ix.de", :a => 1 )
    assert_equal "http://ix.de?a=1", CGI.url_for("http://ix.de", [ [ :a, 1 ]] )
    assert_equal "http://ix.de?a=1&b=bb", CGI.url_for("http://ix.de", [ [ :a, 1 ], [ :b, :bb ]] )
    assert_equal "http://ix.de?a=b%3D1", CGI.url_for("http://ix.de", :a => "b=1" )
  end

  def test_url_for_merging
    assert_equal "http://ix.de/a/b", CGI.url_for("http://ix.de", "a", "b")
    assert_equal "http://ix.de/a/b", CGI.url_for("http://ix.de/", "a/", "b")
    assert_equal "http://ix.de/a/b", CGI.url_for("http://ix.de/", "/a/", "/b/")
    assert_equal "http://ix.de//x/y", CGI.url_for("http://ix.de//", "/x/y")
    assert_equal "http://ix.de//x///y", CGI.url_for("http://ix.de//", "/x///y")
  end
end if VEX_TEST == "base"
