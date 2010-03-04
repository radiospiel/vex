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
      RAILS_ROOT
    elsif defined?(APP_ROOT)
      APP_ROOT
    else
      raise "Cannot determine application root"
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
end

module App::Etest
  def test_app
    assert_not_nil(App.root)
  end
end
