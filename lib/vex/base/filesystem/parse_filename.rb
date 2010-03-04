class File
  def self.basename_wo_ext(s)
    bn = File.basename(s)
    if bn =~ /^(.*)\.([^.]*)$/
      $1
    else
      bn
    end
  end

  #
  # File.extname_wo_dot("x.y") => "y"
  # File.extname_wo_dot("x.") => ""
  # File.extname_wo_dot(".y") => ""
  # File.extname_wo_dot("x") => ""
  #
  def self.extname_wo_dot(s)
    File.extname(s) =~ /^\.([^.]*)$/ ? $1 : ""
  end
end

module File::Etest
  def test_extname_wo_dot
    assert_equal "y", File.extname_wo_dot("x.y")
    assert_equal "", File.extname_wo_dot("x.")
    assert_equal "", File.extname_wo_dot(".y")
    assert_equal "", File.extname_wo_dot("x")
  end

  def test_basename_wo_ext
    assert_equal "x", File.basename_wo_ext("x.y")
    assert_equal "x", File.basename_wo_ext("x.")
    assert_equal "", File.basename_wo_ext(".y")
    assert_equal "x", File.basename_wo_ext("x")
  end
end if VEX_TEST == "base"
