module EmbeddedTest::DummyTest
  def self.counter
    @counter ||= 0
  end

  def self.counter=(c)
    @counter = c
  end
  
  module Etest
    def test_1
      EmbeddedTest::DummyTest.counter += 1
    end
  end
end
