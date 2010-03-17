module CustomValidations
  def validates_url(*args)
    opts = { 
      :scheme => %w(http https) 
    }.update(args.extract_options!)
 
    validates_each(args, opts) do |r, attr, value|
      next unless msg = CustomValidations.invalid_url?(value, opts)
      r.errors.add(attr, msg)

      false
    end
  end

  def self.invalid_url?(url, opts = {})
    return if url.respond_to?(:blank?) && url.blank? && opts[:allow_nil]

    uri = url.is_a?(URI) ? url : URI.parse(url)

    schemes = [ opts[:scheme] || %w(http https) ].flatten.compact 
    if !schemes.empty? && (schemes != :any && !schemes.include?(uri.scheme))
      "Unsupported protocol '#{uri.scheme}', must be one of #{schemes.join(", ")}"
    elsif uri.scheme == "file" && !uri.path
      "Invalid file: URL, needs a path"
    end
  rescue URI::InvalidURIError
    return $!.to_s
  end

  #
  # custom pared.
  #
  
  def self.invalid_parsed?(value, opts, &block)
    return if value.nil? && opts[:allow_nil]

    begin
      value = yield(value)
    rescue
      return $!.to_s
    end

    return "must be in #{opts[:in].inspect}"            if opts[:in] && !opts[:in].include?(value)
    return "Must be greater than #{opts[:gt].inspect}"  if opts[:gt] && !(value > opts[:gt])
    return "Must be >= #{opts[:ge].inspect}"            if opts[:ge] && !(value >= opts[:ge])
    return "Must be less than #{opts[:gt].inspect}"     if opts[:lt] && !(value < opts[:lt])
    return "Must be <= #{opts[:ge].inspect}"            if opts[:le] && !(value <= opts[:le])
  end
  
  def validates_parsed(*args, &block)
    opts = args.extract_options!

    validates_each(args, opts) do |r, attr, value|
      msg = CustomValidations.invalid_parsed?(value, opts, &block)
      r.errors.add attr, msg if msg
      !msg
    end
  end

  def validates_texta(*args)
    validates_parsed(*args) { |value|
      begin
        value.texta
      rescue Texta::Error
        raise "I do not understand: '#{$!.to_s}'"
      end
    }
  end
  
  def validates_integer(*args)
    validates_parsed(*args) { |value| Integer(value) }
  end
  
  def validates_float(*args)
    validates_parsed(*args) { |value| Float(value) }
  end
end

ActiveRecord::Base.extend CustomValidations
