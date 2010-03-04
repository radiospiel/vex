class Thread
  (class << self; self; end).class_eval do
    public :sleep
  end
end

module Thread::Etest
  def test_sleep
    Thread.sleep 0.001
  end
end
