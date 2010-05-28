module File::Write
  def touch(*files)
    opts = if files.last.is_a?(Hash)
      files.pop
    else
      {}
    end
    
    files.each do |file|
      if File.exists?(file)
        File.open(file, "a") {}
      else
        File.write(file, opts[:content])
      end
    end
  end

  def write(path, data)
    File.open(path, "w+") do |file|
      file.write(data) if data
    end
    path
  end
end

File.extend File::Write

module File::Write::Etest
  TESTFILE = "#{__FILE__}.test"
  
  def setup
    File.unlink TESTFILE if File.exist?(TESTFILE)
  end

  def teardown
    File.unlink TESTFILE if File.exist?(TESTFILE)
  end
  
  def test_touches
    assert !File.exist?(TESTFILE)
    File.touch TESTFILE
    assert File.exist?(TESTFILE)
    File.touch TESTFILE
    assert File.exist?(TESTFILE)
    File.unlink TESTFILE
    assert !File.exist?(TESTFILE)
  end
  
  def test_touch_w_content
    assert !File.exist?(TESTFILE)

    File.touch TESTFILE, :content => "TEST CONTENT"
    assert_equal "TEST CONTENT", File.read(TESTFILE)

    File.touch TESTFILE, :content => "TEST CONTENT2"
    assert_equal "TEST CONTENT", File.read(TESTFILE)

    File.unlink TESTFILE
    assert !File.exist?(TESTFILE)
  end

  def test_writes
    assert !File.exist?(TESTFILE)
    File.write TESTFILE, "blabber"
    assert_equal("blabber", File.read(TESTFILE))
    File.write TESTFILE, "bla"
    assert_equal("bla", File.read(TESTFILE))
    File.write TESTFILE, ""
    assert_equal("", File.read(TESTFILE))
    File.unlink TESTFILE
    assert !File.exist?(TESTFILE)
  end
end if VEX_TEST == "base"
