# compare config/local.yml and config/local.defaults.yml
#

module LocalConf::Etest
  def test_local_conf
    LocalConf.x = "xx"
    assert_equal("xx", LocalConf.x)

    LocalConf.x = "yy"
    assert_equal("yy", LocalConf.x)

    assert_equal("dont_overwrite_me", LocalConf.dont_overwrite_me)
    assert_equal(true, LocalConf.dont_overwrite_me?)

    assert_equal false, LocalConf.adverts?

    assert_equal false, LocalConf.ads?
  end

  def test_w_missing_local_conf
    assert_raise(Errno::ENOENT) {  
      LocalConf.new "missing"
    }
  end
end
