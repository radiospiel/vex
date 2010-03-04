module File::Write
  def touch(*files)
    files.each do |file|
      File.open(file, "w") do |f|
      end
    end
  end

  def write(path, data)
    File.open(path, "w+") do |file|
      file.write(data)
    end
    path
  end
end

File.extend File::Write

module File::Write::Etest
  TESTFILE = "#{__FILE__}.test"
  
  def test_touches
    assert !File.exist?(TESTFILE)
    File.touch TESTFILE
    assert File.exist?(TESTFILE)
    File.touch TESTFILE
    assert File.exist?(TESTFILE)
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
end
