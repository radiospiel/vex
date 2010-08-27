require "cgi"

class CGI
  def self.build_url(url_base, opts = {})
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
  def test_build_url
    assert_equal "http://ix.de", CGI.build_url("http://ix.de")
    assert_equal "http://ix.de?a", CGI.build_url("http://ix.de", :a => nil)
    assert_equal "http://ix.de?a", CGI.build_url("http://ix.de", [ :a ])
    assert_equal "http://ix.de?a=1", CGI.build_url("http://ix.de", :a => 1 )
    assert_equal "http://ix.de?a=1", CGI.build_url("http://ix.de", [ [ :a, 1 ]] )
    assert_equal "http://ix.de?a=1&b=bb", CGI.build_url("http://ix.de", [ [ :a, 1 ], [ :b, :bb ]] )
    assert_equal "http://ix.de?a=b%3D1", CGI.build_url("http://ix.de", :a => "b=1" )
  end
end if VEX_TEST == "base"
