module FileUtils::TmpFile
  def self.counter
    Thread.current["tmpfiles"] ||= 0
    Thread.current["tmpfiles"] += 1
  end
  
  #
  # tmpfile("xx.jpg") do |dest|
  #   Net.download("http://xx.yy.zz/a.jpg", dest)
  # end
  #
  # the block gets the temp file name, which is guaranteed to be
  # unique amongst all running processes.
  #
  # If the path parameter is set the temporary file will be fastcopied 
  # to that output file.
  def tmpfile(path=nil, &block)
    raise ArgumentError, "This no longer supports Symbol parameters" if path.is_a?(Symbol)
    ext = "#{Thread.uid}_#{FileUtils::TmpFile.counter}"
    
    case path
    when nil    
      tmp = "#{App.tmpdir}/data.#{ext}"
    else
      Dir.mkdirs(File.dirname(path))
      tmp = "#{path}.tmp#{ext}"
    end
    
    begin
      result = yield(tmp)
      if result != false && path && File.exist?(tmp)
        FileUtils.fast_copy(tmp, path)
      end
      return result
    ensure
      File.unlink(tmp) if File.exists?(tmp)
    end
  end
end

FileUtils.extend FileUtils::TmpFile

module FileUtils::TmpFile::Etest
  def test_tmpfile
    assert File.exist?(__FILE__)

    # so something successfully via a tmp file
    FileUtils.fast_copy __FILE__, "tmp/copy.dat"
    assert File.exist?("tmp/copy.dat")
    
    FileUtils.tmpfile "tmp/copy.dat" do |dest|
      false
    end

    assert_equal File.size(__FILE__), File.size("tmp/copy.dat")

    FileUtils.tmpfile "tmp/copy.dat" do |dest|
      File.write(dest, "hey")
    end

    assert_equal 3, File.size("tmp/copy.dat")

    FileUtils.fast_copy __FILE__, "tmp/copy.dat"
    assert_equal File.size(__FILE__), File.size("tmp/copy.dat")

    FileUtils.tmpfile "tmp/copy.dat" do |dest|
      File.write(dest, "hey")
      false
    end
    
    assert_equal File.size(__FILE__), File.size("tmp/copy.dat")

    FileUtils.tmpfile "tmp/copy.dat" do |dest|
      File.write(dest, "hey")
      nil
    end

    assert_equal 3, File.size("tmp/copy.dat")

    r = FileUtils.tmpfile "tmp/copy.dat" do |dest|
      File.write(dest, "hey")
      "fourfour"
    end

    assert_equal "fourfour", r
  end
end if VEX_TEST == "base"
