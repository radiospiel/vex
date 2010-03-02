module ObjectExt::MultipleAttributes
  def self.included(klass)
    klass.extend ClassMethods
  end
  
  module ClassMethods
    def attributes(*args)
      writable_flag = args.last
      if writable_flag != true && writable_flag != false
        writable_flag = false
      else
        args.pop
      end

      args.each do |arg|
        attr arg, writable_flag
      end
    end
  end
end
