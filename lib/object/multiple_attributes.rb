class Module
  module MultipleAttributes
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

  include MultipleAttributes
end
