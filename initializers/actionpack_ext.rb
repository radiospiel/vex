class ActionController::Base
  extend AutoLoader
  include VerifyAction
#  include CachedUrlWriter
  include SecureUrlWriter
end
