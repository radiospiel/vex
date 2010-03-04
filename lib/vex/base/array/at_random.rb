module Array::AtRandom
  def at_random
    self[Kernel.rand(length)] unless empty?
  end
end

Array.send :include, Array::AtRandom

module Array::AtRandom::Etest
  def test_at_random
    array = [ 1, 2, 3, 4, 5 ]
    5.times do
      assert array.include?(array.at_random)
    end
    assert_equal nil, [].at_random
  end
end if VEX_TEST == "base"
