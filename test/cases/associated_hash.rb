module AssociatedHash; end

module AssociatedHash::Etest
  def test_urls
    item = RandomBase.find(:first) || RandomBase.create!

    assert_equal({}, item.urls)

    item.urls[:pic_small] = "pic_small"
    assert_equal({:pic_small => "pic_small"}, item.urls)
    assert_equal("pic_small", item.urls[:pic_small])
    assert_equal("pic_small", item.urls["pic_small"])
    assert_equal(nil, item.urls[:missing])

    item.reload
    assert_equal({:pic_small => "pic_small"}, item.urls)
    assert_equal("pic_small", item.urls[:pic_small])
    assert_equal("pic_small", item.urls["pic_small"])
    assert_equal(nil, item.urls[:missing])

    item.urls[:pic_small] = nil
    
    item.reload
    assert_equal({}, item.urls)
  end

  def test_mass_assign_urls
    item = RandomBase.find(:first) || RandomBase.create!

    item.urls = {
      :pic_small => "pic_small",
      :pic_large => "pic_large" 
    }

    assert_equal("pic_small", item.urls[:pic_small])
    assert_equal("pic_large", item.urls[:pic_large])

    item.urls.clear
    assert_equal({}, item.urls)
  end
end
