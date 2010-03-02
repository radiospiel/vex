require 'socket'  

#
# see http://coderrr.wordpress.com/2008/05/28/get-your-local-ip-address/
#
class Socket
  #
  # Parameters:
  #
  # * when_talking_to: returns my IP when talking to that host.
  # * when_talking_to: returns my IP when talking to that host.
  
  # do_raise is mainly for test purposes
  def self.local_ip(when_talking_to = nil, do_raise = false)
    when_talking_to ||= '64.233.187.99'
    begin
      orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily  
  
      UDPSocket.open do |s|  
        s.connect when_talking_to, 1  
        s.addr.last  
      end  
    rescue
      raise if do_raise
      "127.0.0.1" # not connected to the funny wide web?
    ensure  
      Socket.do_not_reverse_lookup = orig  
    end
  end

  def self.online?
    local_ip("google.com") != "127.0.0.1"
  end
end

module Socket::Etest
  def test_returns_127_locally
    require 'ipaddr'
    local_net = IPAddr.new("127.0.0.0/24")
    %w(127.0.0.1 127.0.0.2 localhost).each do |ip|
      assert(local_net.include?(IPAddr.new(Socket.local_ip(ip))))
    end
  end

  def test_returns_127_invalid
    UDPSocket.stubs(:open).raises(RuntimeError)

    assert_raises(RuntimeError) {
      Socket.local_ip("whatever", true)
    }
    
    assert_equal("127.0.0.1", Socket.local_ip("whatever"))
  end

  # TODO: how can we test that otherwise??
end
