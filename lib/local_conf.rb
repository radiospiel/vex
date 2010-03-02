class LocalConf < Hash
  include Hash::SimpleAccessMethods
  include Hash::SimpleAccessMethods::AutoCreate

  def initialize(file)
    load file.sub(/\.yml$/, ".defaults.yml")
    load file, RAILS_ENV
  end
  
  private
  
  def load(file, key = nil)
    begin
      data = YAML::load_file("#{RAILS_ROOT}/config/#{file}")
      data = data[key] if data && key
      data.each { |k,v| update k.to_sym => v } if data
    rescue Errno::ENOENT
      {}
    end
  end

  def method_missing(sym, *args)
    return super unless sym.to_s =~ /^(.*)\?$/
    !!super($1, *args)
  end

  # -- the global local conf object... ---------------
  
  def self.method_missing(sym, *args, &block)
    local_conf.send sym, *args, &block
  end

  def self.local_conf
    if defined?(Rails) && Rails.env.development?
      @local_conf = nil
    end
    
    @local_conf ||= LocalConf.new("local.yml")
  end

  def self.inspect
    local_conf.inspect
  end

  def self.revision
    @revision ||= begin
      "r#{File.read("#{RAILS_ROOT}/REVISION")}"
    rescue Errno::ENOENT
      ""
    end 
  end
end

module LocalConf::Etest
  def test_local_conf
    LocalConf.x = "xx"
    assert_equal("xx", LocalConf.x)

    LocalConf.x = "yy"
    assert_equal("yy", LocalConf.x)

    assert_equal("dont_overwrite_me", LocalConf.dont_overwrite_me)
    assert_equal(true, LocalConf.dont_overwrite_me?)
  end

  def test_w_local_conf_test
  end
end
