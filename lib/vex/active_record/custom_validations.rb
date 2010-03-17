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

    if !uri.scheme
      return "Missing URI protocol"
    end

    schemes = [ opts[:scheme] || %w(http https) ].flatten.compact 

    return if schemes.include?(:any) || schemes.empty?

    if !schemes.include?(uri.scheme)
      return "Unsupported protocol #{uri.scheme.inspect}, must be one of #{schemes.join(", ")}"
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

module CustomValidations::Etest
  class CVModel < ActiveRecord::Base
    validates_url :url, :scheme => :any
  end
  
  def test_lite_table
    CVModel.lite_table do
      string :url
    end

    cv = CVModel.new :url => "http://xx.yy"
    assert cv.valid?

    cv = CVModel.new :url => "data://xx.yy"
    assert cv.valid?

    cv = CVModel.new :url => "file:xx.yy"
    assert cv.valid?

    cv = CVModel.new :url => "illegal"
    assert !cv.valid?
  end
end

