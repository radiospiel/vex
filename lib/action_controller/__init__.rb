if defined?(ActionController)

  class ActionController::Base
    extend AutoLoader
    include VerifyAction
    include SecureUrlWriter
  end

end
