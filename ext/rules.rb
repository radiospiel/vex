__END__

class ActionController::Base
  def self.rules(file=nil)
    # Note: this does not inherit!
    @rules = File.read("#{RAILS_ROOT}/app/views/rules/#{file}.rules") if file
    @rules
  end
end

class ActionView::Base
  def rules(rules=nil)
    @rules ||= Rules.new(self).compile(controller.class.rules)
    @rules.compile(rules)
  end
end
