class ActionController::Base
  def self.whitelist_actions(*names)
    extend WhitelistActions
    include WhitelistControllerActions

    before_filter :verify_whitelisted_actions

    actions *names
  end

  module WhitelistControllerActions
    def verify_whitelisted_actions
      return if self.class.name.starts_with?("Clearance::")

      valid_actions = self.class.whitelisted_actions
      return if valid_actions == :skip || valid_actions.include?(action_name)

      unless Rails.env.development?
        error 404, "This page doesn't exist"
        return
      end

      error 404, <<-TEXT
No such action exists: #{controller_name}##{action_name}.
Note: this application uses the whitelisted_actions plugin,
you might have to use the 'actions' method to whitelist your actions.
TEXT
    end
  end
  
  module WhitelistActions
    def whitelisted_actions
      @whitelisted_actions ||
      (superclass.respond_to?(:whitelisted_actions) ? superclass.whitelisted_actions : nil)
    end
    
    def skip_whitelist_actions
      @whitelisted_actions = :skip
    end
    
    def actions(*names)
      @whitelisted_actions = names.map(&:to_s).to_set
    end
  end
end
