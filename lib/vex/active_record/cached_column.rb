module ActiveRecord::Extension::CachedColumn
  DEFAULTS = {
    :time_to_live => 5.minutes
  }
  
  def self.included(klass)
    klass.extend ClassMethods
  end
  
  module ClassMethods
    #
    # cached_column :name, :time_to_live => 5.minutes
    def cached_column(name, options = ActiveRecord::Extension::CachedColumn::DEFAULTS, &block)
      #
      # create the "#{name}_updated_at_column"
      lite_table do
        datetime "#{name}_updated_at"
      end
      
      define_method(name) do
        read_cached_column(name, options, Proc.new)
      end
      
      define_method("#{name}!") do
        write_attribute "#{name}_updated_at", nil
        self.send name
      end
      
      define_method("#{name}=") do |v|
        write_cached_column(name, v)
      end
    end
  end

  private
  
  def write_cached_column(name, value)
    write_attribute name, value
    write_attribute "#{name}_updated_at", Time.now
  end
  
  def read_cached_column(name, options, proc)
    updated_at = self.send("#{name}_updated_at")
    r = if updated_at && updated_at + options[:time_to_live] > Time.now
      read_attribute(name)
    else
      value = if proc.arity <= 0  then proc.bind(self).call
      elsif proc.arity == 1       then proc.call(self)
      else                        raise "Unsupported # of block parameters"
      end
      
      update_attributes! name => value
      value
    end
    
    r = r.slop if r.respond_to?(:slop)
    r
  end
end

ActiveRecord::Base.send :include, ActiveRecord::Extension::CachedColumn
