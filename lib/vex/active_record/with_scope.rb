module ActiveRecord::Extension::WithScope
  
  def self.included(klass)
    #
    # add a custom scope. 
    klass.named_scope :with, lambda { |*args| ActiveRecord::Extension::WithScope.options(*args) }
  end
  
  def self.options(*args)
    options = args.extract_options!
    if options[:conditions] && !args.empty?
      raise "Cannot have multiple condition entries"
    end

    unless args.empty?
      options = { :conditions => args }.update(options)
    end

    options
  end
end

ActiveRecord::Base.send :include, ActiveRecord::Extension::WithScope
