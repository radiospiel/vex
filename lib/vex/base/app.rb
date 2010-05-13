module App
  def self.rails?
    defined?(RAILS_ROOT)
  end

  def self.revision
    @revision ||= begin
      "r#{File.read("#{root}/REVISION")}"
    rescue Errno::ENOENT
      ""
    end 
  end

  def self.env
    if rails?
      RAILS_ENV
    elsif defined?(APP_ENV)
      APP_ENV
    else
      "production"
    end
  end

  def self.development?
    env == "development"
  end

  def self.production?
    env == "production"
  end

  def self.test?
    env == "test"
  end
  
  def self.root
    @root ||= begin
      if defined?(RAILS_ROOT)
        RAILS_ROOT
      elsif defined?(APP_ROOT)
        APP_ROOT
      elsif defined?($0)
        File.expand_path File.dirname($0)
      else
        raise "Cannot determine application root"
      end
    end
  end

  def self.logger
    if rails?
      RAILS_DEFAULT_LOGGER
    else
      require "logger"

      logdir = "#{root}/log"
      FileUtils.mkdir_p logdir
      Logger.new "#{logdir}/#{env}.log"
    end
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

  def self.local_conf
    @local_conf = nil if App.env == "development"
    @local_conf ||= LocalConf.new("local.yml")
  end
end

module App::Etest
  def test_app
    assert_not_nil(App.root)
  end

  def test_app
    assert_equal("", App.revision)
  end
end if VEX_TEST == "base"
