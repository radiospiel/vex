module EmbeddedTest::Etest
  def test_etest
    EmbeddedTest::DummyTest.counter = 0
    EmbeddedTest.run EmbeddedTest::DummyTest
    assert EmbeddedTest::DummyTest.counter > 0
  end
end
