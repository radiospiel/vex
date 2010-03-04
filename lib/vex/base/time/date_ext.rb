class Date
  def first_of_month
    self - self.day + 1
  end
end

module Date::Etest
  def test_first_of_month
    date = Date.parse("2010/02/28")
    assert_equal Date.parse("2010/02/01"), date.first_of_month
  end
end
