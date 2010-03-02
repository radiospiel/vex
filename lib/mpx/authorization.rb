#
# a small HTTP header based authorization module, for use with
# internal API controllers.
module Mpx::Authorization
  # The HTTP header
  HEADER = "X-MPX-Authorization"

  # verifies authorization header for a server. Pass in the request object
  def self.valid?(s)
    s.headers[HEADER] =~ /^true/i
  end

  # set authorization header for a client, which sends via \a ip 
  def self.authorize(headers)
    headers.update HEADER => "true"
  end
end
