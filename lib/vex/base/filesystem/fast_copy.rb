module FileUtils::FastCopy
  # fast_copy a file: This hardlinks the source file to the destfile,
  # if possible. src must refer to a file; dest must refer to a file
  # or not exist at all.
  def fast_copy(src, dest)
    src_stat = File.stat(src)
    invalid_argument!(src, "This is not a file") unless src_stat.file?
    
    dest_stat = begin
      File.stat(dest) 
    rescue Errno::ENOENT
    end
    
    invalid_argument!(dest) unless !dest_stat || dest_stat.file?
    
    dest_dev = dest_stat ? dest_stat.dev : begin
      dest_dir = File.dirname(File.expand_path(dest))
      File.stat(dest_dir).dev
    end

    if src_stat.dev == dest_dev
      File.unlink(dest) if File.exists?(dest)
      File.link src, dest
    else
      FileUtils.copy src, dest
    end
  end
end

FileUtils.extend FileUtils::FastCopy

module FileUtils::FastCopy::Etest
  def test_fast_copy
    File.unlink("tmp/somedata.dat") if File.exist?("tmp/somedata.dat")

    assert !File.exist?("tmp/somedata.dat")
    FileUtils.fast_copy __FILE__, "tmp/somedata.dat"
    assert_equal File.read("tmp/somedata.dat"), File.read(__FILE__)

    File.unlink("tmp/somedata.dat")
    File.touch("tmp/somedata.dat")
    assert_not_equal File.size("tmp/somedata.dat"), File.size(__FILE__)
    FileUtils.fast_copy __FILE__, "tmp/somedata.dat"
    assert_equal File.size("tmp/somedata.dat"), File.size(__FILE__)
  end

  def test_fast_copy_failures
    assert_raise(Errno::ENOENT) {  
      FileUtils.fast_copy "fixtures/somedata.dat.nonexisting", "tmp/somedata.dat"
    }

    assert_raise(Errno::ENOENT) {  
      FileUtils.fast_copy "fixtures/somedata.dat.nonexisting", "tmp"
    }

    assert_raise(Errno::ENOENT) {  
      FileUtils.fast_copy __FILE__, "tmp/nonexisting/dir"
    }
  end

  def test_fast_copy_slow
    File.touch("tmp/somedata.dat")
    assert File.exist?("tmp/somedata.dat")

    File.stubs(:stat).with(__FILE__).returns({ :file => true, :dev => 1 }.slop)
    File.stubs(:stat).with("tmp/somedata.dat").returns({ :file => true, :dev => 2 }.slop)

    FileUtils.expects(:copy).with(__FILE__, "tmp/somedata.dat")
    FileUtils.fast_copy __FILE__, "tmp/somedata.dat"

    File.unlink("tmp/somedata.dat")
  end

end if VEX_TEST == "base"
