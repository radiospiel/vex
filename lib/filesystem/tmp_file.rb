module FileUtils::TmpFile
  #
  # tmpfile("xx.jpg") do |dest|
  #   Net.download("http://xx.yy.zz/a.jpg", dest)
  # end
  #
  # the block gets the temp file name, which is guaranteed to be
  # unique amongst all running processes.
  def tmpfile(path=nil, &block)
    ext = "#{$$}_#{Thread.current.object_id}_tmp"
    case path
    when nil    
      tmp = "tmp/t_#{ext}"
    when Symbol 
      tmp, path = "tmp/t_#{ext}.#{path}", nil
    else
      Dir.mkdirs(File.dirname(path))
      tmp = "#{path}.#{ext}"
    end
    
    begin
      result = yield(tmp)
      FileUtils.fast_copy(tmp, path) if File.exist?(tmp) && path && result != false
      returning(result) do
        File.unlink(tmp) if File.exists?(tmp)
      end
    rescue
      if File.exists?(tmp)
        File.unlink(tmp) if !RAILS_ENV || RAILS_ENV == "production"
      end
      
      raise
    end
  end
end

FileUtils.extend FileUtils::TmpFile

module FileUtils::TmpFile::Etest
  def test_tmpfile
    assert File.exist?("fixtures/somedata.dat")

    # so something successfully via a tmp file
    FileUtils.fast_copy "fixtures/somedata.dat", "tmp/copy.dat"
    assert File.exist?("tmp/copy.dat")
    
    FileUtils.tmpfile "tmp/copy.dat" do |dest|
      false
    end

    assert_equal File.size("fixtures/somedata.dat"), File.size("tmp/copy.dat")

    FileUtils.tmpfile "tmp/copy.dat" do |dest|
      File.write(dest, "hey")
    end

    assert_equal 3, File.size("tmp/copy.dat")

    FileUtils.fast_copy "fixtures/somedata.dat", "tmp/copy.dat"
    assert_equal File.size("fixtures/somedata.dat"), File.size("tmp/copy.dat")

    FileUtils.tmpfile "tmp/copy.dat" do |dest|
      File.write(dest, "hey")
      false
    end
    
    assert_equal File.size("fixtures/somedata.dat"), File.size("tmp/copy.dat")

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
end
