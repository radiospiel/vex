module NokogiriExt
  def full_name
    ns = namespace
    ns ? "#{ns}:#{name}" : name
  end

  def transform(&block)
    case r = yield(self)
    when false
      self.remove
    when String
      Nokogiri::HTML.fragment(r).children.each do |n|
        add_previous_sibling n
      end

      self.remove
    when Nokogiri::XML::Node
      add_previous_sibling r
      self.remove
    else
      children.each do |child| child.transform(&block) end
    end
  end
  
  def remove_blanks
    transform do |n|
      n.name != "text" || !n.text.blank?
    end
  end
end

class Nokogiri::XML::Node
  include NokogiriExt
end

class Nokogiri::XML::Document
  private :transform
end

module NokogiriExt::Etest
  SOURCE = <<-XML
<bb>
<i:xy></i:xy>
</bb>
XML

  def assert_xml_equals(expected, actual)
    expected = Nokogiri::XML(expected)
    
    if expected == actual 
      assert true
      return
    end
    
    expected = expected.remove_blanks
    actual = actual.remove_blanks

    if expected == actual 
      assert true
      return
    end

    expected = expected.to_s.gsub(/<\?xml version=\"1.0\"\?>\n/, "")
    actual = actual.to_s.gsub(/<\?xml version=\"1.0\"\?>\n/, "")

    assert_equal expected, actual
  end

  def test_assertion
    doc = Nokogiri::XML SOURCE
    assert_xml_equals SOURCE, doc
  end

  def test_transform
    doc = Nokogiri::XML SOURCE
    doc.root.transform do |s| "<cc />" end
    assert_xml_equals "<cc/>", doc

    doc = Nokogiri::XML SOURCE
    doc.root.transform do |s| s.name != "xy" end
    assert_xml_equals "<bb/>", doc 
  end
  
  def test_transform2
    doc = Nokogiri::XML SOURCE
    doc.root.transform do |s| 
      if s.name == "xy"
        "<cc />" 
      elsif s.name == "text" && s.text.blank?
        false
      end
    end

    assert_xml_equals "<bb><cc/></bb>", doc
  end
end
