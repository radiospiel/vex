module File::Lock
  #
  # File.locked implements recursive locking based on lock files. 
  def locked(path, &block)
    file = File.open "#{path}.lck", "w+"
    begin
      # First try to lock the file nonblockingly.
      # Failing that it might be already locked by *this* process. 
      # Otherwise it is locked by someone else.
      if locked = file.flock(File::LOCK_EX | File::LOCK_NB)
        File.write("#{path}.pid", Thread.uid)
      elsif File.read("#{path}.pid") == Thread.uid
        # already locked by us.
      else
        locked = file.flock(File::LOCK_EX)
      end

      yield
    ensure
      file.flock(File::LOCK_UN) if locked
    end
  end
end

File.extend File::Lock

module File::Lock::Etest
  TESTFILE = "#{__FILE__}.test"

  def test_lock
    i = 1
    File.locked TESTFILE do
      File.locked TESTFILE do
        i = 2
      end
    end
    
    assert_equal(2, i)
  end

  def test_lock_unsuccessful
  end
end
