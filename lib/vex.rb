module Vex
  def self.add_path(path, array=nil)
    if array
      array.unshift(path) unless array.include?(path)
      return
    end
    
    return unless File.directory?(path)
    add_path path, $:
    add_path path, ActiveSupport::Dependencies.load_paths
  end
  
  def self.require_subdir(path)
    path = Pathname.new(path).realpath rescue nil
    return if path.nil?

    Dir.glob("#{path}/**/*.rb").sort.each do |ext|
      next if ext =~ /\/test\//

      STDERR.print "." unless RAILS_ENV == "production"
      require "#{ext}"
    end
  end
end
