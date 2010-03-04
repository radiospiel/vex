class LocalConf < Hash
  include Hash::EasyAccess
  
  def initialize(file)
    r1 = load file.sub(/\.yml$/, ".defaults.yml")
    r2 = load file, App.env

    return if r1 || r2
    
    raise Errno::ENOENT, 
      "Missing configuration file #{App.root}/config/#{file.sub(/\.yml$/, "")}{.defaults}.yml}"
  end

  private
  
  def load(file, key = nil)
    data = YAML::load_file("#{App.root}/config/#{file}")
    data = data[key] if data && key
    data.each { |k,v| update k.to_sym => v } if data
    true
  rescue Errno::ENOENT
    false
  end
  
  def method_missing(sym, *args, &block)
    return super unless args.empty? && !block_given? && sym.to_s =~ /(.*)\?/
    !fetch($1.to_sym).blank?
  rescue IndexError
    false
  end

  def self.method_missing(sym, *args, &block)
    App.local_conf.send sym, *args, &block
  end
end
