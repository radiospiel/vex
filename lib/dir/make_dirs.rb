
module Dir::MakeDirs
  def exists?(path)
    begin
      Dir.open(path) && true
    rescue Errno::ENOENT, Errno::ENOTDIR
      false
    end
  end
  
  def mkdirs(path)
    paths = path.split("/")
    paths.each_with_index do |path, idx|
      p = paths[0..idx].join("/")
      next if p.empty?      # This is root
      next if exists?(p)
      mkdir(p)
    end
  end

  def rmdirs(path)
    Dir.glob("#{path}/**/*", File::FNM_DOTMATCH).sort.reverse.each do |file|
      if File.directory?(file)
        next if file =~ /\/\.\.?$/
        Dir.rmdir(file)
      else
        File.unlink(file)
      end
    end

    Dir.rmdir(path)
  end

  TMPBASE = "#{RAILS_ROOT}/tmp"
  
  def tmp(do_unlink = true, &block)
    path = "#{TMPBASE}/#{$$}_#{Thread.current.object_id}"
    Dir.mkdirs path
    returning(yield(path)) do 
      Dir.rmdirs(path) if do_unlink
    end
  rescue
    Dir.rmdirs(path) if do_unlink && (!RAILS_ENV || RAILS_ENV == "production")
    raise
  end
end


module Dir::MakeDirs::Etest
  def test_mkdirs
    base = File.dirname(__FILE__) + "/dirtest"
    
    assert !Dir.exists?(base)
    Dir.mkdirs "#{base}/a/b/c"
    Dir.mkdirs "#{base}/a/b/.dot"
    assert Dir.exists?(base)
    assert Dir.exists?("#{base}/a/b/c")

    File.touch "#{base}/a/b/x.y"
    File.touch "#{base}/a/b/.x.y"
    File.touch "#{base}/a/b/..x.y"
    File.touch "#{base}/a/b/.dot/a"

    Dir.rmdirs("#{base}")
    assert !Dir.exists?(base)
    assert !Dir.exists?("#{base}/a/b/c")
  end

  def test_exists
    assert Dir.exists?(File.dirname(__FILE__))
    assert !Dir.exists?(__FILE__)
    assert !Dir.exists?(__FILE__ + ".unknown")
    assert !Dir.exists?(__FILE__ + ":invalid")
  end

  def test_tmpdir
    p = nil
    Dir.tmp do |pdir|
      p = pdir
    end
    
    assert p.starts_with?(Dir::MakeDirs::TMPBASE)
    assert !File.exist?(p)
  end
end
