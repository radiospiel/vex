require "net/http"
require "net/https"

module Net::HTTPExt; end

Net.extend Net::HTTPExt

#
# This adds Net.get, Net.head, Net.post
module Net::HTTPExt
  REDIRECTION_LIMIT = 10

  DEFAULT_OPTIONS = {
    :redirect => 10     # MAX # of redirection
  }
  
  # This is a combination of a string (for the response body) and
  # of a "hash" for the response header
  class Response < String
    class Headers
      attr :code, true
        
      def initialize(response)
        @headers = response.instance_variable_get "@header"
      end

      def method_missing(sym, *args, &block)
        return super unless args.empty? && !block_given?
        self[sym]
      end

      def [](key)
        r = @headers[key.to_s.downcase.gsub("_", "-")]
        raise "huh?" unless r.is_a?(Array) 
        r.length <= 1 ? r.first : r
      end
    end

    attr :response
    attr :headers

    def code;     Integer(response.code); end
    def good?;    code >= 200 && code < 300; end
    def message;  response.message;       end
    
    def initialize(response)
      super(response.body) if response.body
      @response, @headers = response, Headers.new(response)
    end
  end

  # POST request
  def post(url, body, opts = {})
    http :post, url, body, opts
  end

  # HEAD request
  def head(url, opts = {})
    http :head, url, nil, opts
  end

  # GET request
  def get(url, opts = {})
    http :get, url, nil, opts
  end

  def exists?(url, opts = {})
    r = Net.head(url, opts)
    r.code >= 200 && r.code < 300
  end

  alias :exist? :exists?

  HEADERS_KEY = :"net:http_ext:preprocessors:headers"

  def headers
    Thread.current[HEADERS_KEY] ||= {}
  end

  def headers=(h)
    Thread.current[HEADERS_KEY] = h
  end
  
  def with_headers(scope, &block)
    old = headers
    self.headers = headers.dup.update scope
    yield
  ensure
    self.headers = old
  end
  
  private
  
  def adjust_request!(verb, path, h, body)
    headers.each do |k,v|
      k = k.to_s
      
      if v.respond_to?(:call)
        v.call(verb, path, h, body) 
      elsif v.nil?
        h.delete k
        h.delete k.to_sym
      else
        h[k] ||= v
      end
    end
  end
  
  def http(verb, url, body, opts, &block)
    # -- timeout handling
    if timeout = opts.delete(:timeout)
      begin
        return Timeout.timeout(timeout) { http(verb, url, body, opts, &block) }
      rescue Timeout::Error
        return nil
      end
    end

    headers = DEFAULT_OPTIONS.dup.update(opts)
    redirect = headers.delete :redirect
    
    r = do_http verb, url, body, headers, redirect, &block
    r.headers.code = r.code
    
    verb != :head ? r : r.headers
  end
  
  # connects to a HTTP server, yields the URI and the HTTP connection
  def do_http(verb, url, body, headers={}, redirect = nil, &block)
    # -- connect to the server
    uri = url.is_a?(URI) ? url : URI.parse(url)

    connection = Net::HTTP.new(uri.host, uri.port)
    connection.use_ssl = uri.scheme == "https"
    connection.verify_mode = OpenSSL::SSL::VERIFY_NONE

    invalid_argument!("Invalid URL", url) unless %w(https http).include?(uri.scheme)

    # -- do whatever
    connection.start do |c|
      adjust_request! verb, uri.request_uri, headers, body
      
      args = [ ]
      args << "request_#{verb}"
      args << uri.request_uri
      args << body if verb == :post || verb == :put
      args << headers

      response = connection.send *args

      if !response.is_a?(Net::HTTPRedirection) || !redirect
        next Response.new(response)
      end

      raise "Reached maximum number of redirections" if redirect <= 0

      do_http verb == :head ? :head : :get,
        redirection_url(url, response['location']),
        nil,
        headers,
        redirect - 1
    end
  ensure
    connection.finish if connection && connection.started?
  end

  #
  # fix non default responses. Magento does this, sometimes...
  def redirection_url(uri, location)
    return location if URI.parse(location).scheme rescue nil
    raise "Cannot redirect to URI #{location}" unless uri.to_s =~ /^((.*?)\/\/(.*?)\/)/
    $1 + location.gsub(/^\/+/, "")
  end
end

module Net::HTTPExt::Etest
  def test_w_google_w_redirection
    return unless Socket.online?

    google = Net.get("http://www.google.com")
    assert google =~ /<title>Google/
    assert google.headers["Content-Type"] =~ /text\/html/
    assert google.headers.content_type =~ /text\/html/
  end
   
  def test_w_google_wo_redirection
    return unless Socket.online?

    google = Net.get("http://www.google.com", :redirect => false)
    assert_equal(302 , google.code)
    assert google.headers["Content-Type"] =~ /text\/html/
    assert google.headers.content_type =~ /text\/html/
  end

  def test_w_google
    return unless Socket.online?

    assert Net.exists?("http://www.google.de")
    assert Net.exist?("http://www.google.de")
    
    google = Net.get("http://www.google.de")
    assert google =~ /<title>Google/
    assert google.headers["Content-Type"] =~ /text\/html/
    assert google.headers.content_type =~ /text\/html/
  end

  def test_w_google_timeout
    return unless Socket.online?

    google = Net.get("http://www.google.de", :timeout => 0.01)
    assert_equal(nil, google)
  end

  def test_w_google_adjusted_headers
    return unless Socket.online?

    Net.with_headers :x_abc => "Test ABC" do
      assert_equal("Test ABC", Net.headers[:x_abc])
      assert Net.exists?("http://www.google.de")
      Net.with_headers :x_abc => nil do
        assert_equal(nil, Net.headers[:x_abc])
      end
      assert_equal("Test ABC", Net.headers[:x_abc])
    end
  end
end if VEX_TEST == "base"

