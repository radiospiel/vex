module FileUtils::FastCopy
  # fast_copy a file: This hardlinks the source file to the destfile,
  # if possible. src must refer to a file; dest must refer to a file
  # or not exist at all.
  def fast_copy(src, dest)
    src_stat = File.stat(src)
    invalid_argument!(src) unless src_stat.file?
    
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

module FileUtils::FastCopy::Etest
  def test_fast_copy
    assert File.exist?("fixtures/somedata.dat")
    File.unlink("tmp/somedata.dat") if File.exist?("tmp/somedata.dat")

    assert !File.exist?("tmp/somedata.dat")
    FileUtils.fast_copy "fixtures/somedata.dat", "tmp/somedata.dat"
    assert_equal File.size("tmp/somedata.dat"), File.size("fixtures/somedata.dat")

    File.unlink("tmp/somedata.dat")
    File.touch("tmp/somedata.dat")
    assert_not_equal File.size("tmp/somedata.dat"), File.size("fixtures/somedata.dat")
    FileUtils.fast_copy "fixtures/somedata.dat", "tmp/somedata.dat"
    assert_equal File.size("tmp/somedata.dat"), File.size("fixtures/somedata.dat")
  end

  def test_fast_copy_failures
    assert_raise(Errno::ENOENT) {  
      FileUtils.fast_copy "fixtures/somedata.dat.nonexisting", "tmp/somedata.dat"
    }

    assert_raise(Errno::ENOENT) {  
      FileUtils.fast_copy "fixtures/somedata.dat.nonexisting", "tmp"
    }

    assert_raise(Errno::ENOENT) {  
      FileUtils.fast_copy "fixtures/somedata.dat", "tmp/nonexisting/dir"
    }
  end
end
