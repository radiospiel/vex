class LocalConf < Hash
  include Hash::Slop
  
  def initialize(file)
    r1 = load file.sub(/\.yml$/, ".defaults.yml")
    r2 = load file

    return if r1 || r2
    
    raise Errno::ENOENT, 
      "Missing configuration file #{App.root}/config/#{file.sub(/\.yml$/, "")}{.defaults}.yml}"
  end

  private
  
  def load(file)
    data = YAML::load_file("#{App.root}/config/#{file}")

    data.each { |k,v| update k.to_sym => v }

    if h = data["defaults"]
      h.each { |k,v| update k.to_sym => v }
    end
    if h = data[App.env]
      h.each { |k,v| update k.to_sym => v }
    end

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
