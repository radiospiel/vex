module App
  def self.rails?
    defined?(RAILS_ROOT)
  end

  def self.env
    if rails?
      RAILS_ENV
    else
      "production"
    end
  end
  
  def self.root
    if defined?(RAILS_ROOT)
      return RAILS_ROOT
    end
    
    raise "Cannot determine application root"
  end
  
  def self.tmpdir
    @tmpdir ||= begin
      tmpdir = if rails?
        "#{root}/tmp"
      else
        ENV["TMPDIR"]
      end

      tmpdir = tmpdir.gsub(/\/$/, "")

      raise "Cannot determine tmpdir setting" if tmpdir.blank?
      tmpdir
    end
  end
end
