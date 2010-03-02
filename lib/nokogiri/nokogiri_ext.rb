require 'nokogiri'

module NokogiriExt
  def full_name
    ns = namespace
    ns ? "#{ns}:#{name}" : name
  end

  def ==(other)
    case other
    when Symbol
      name == other.to_s
    else
      other.respond_to?(:pointer_id) && pointer_id == other.pointer_id
    end
  end

  def css_path(start=nil)
    return "" if self == start || self == document

    p = node.parent.css_path(start)
    p += " > " unless p.blank?
    p += node.name
    p += "." + node["class"].gsub(/\s+/, ".") unless node["class"].blank?
    p
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
<xy></xy>
</bb>
XML

  def assert_xml(doc, expected)
    actual = Nokogiri::XML(doc.to_s.gsub(/\n\s*/, "")).to_s
    
    assert_equal("<?xml version=\"1.0\"?>\n#{expected}\n", actual)
  end
  
  def test_transform
    doc = Nokogiri::XML SOURCE
    doc.root.transform do |s| "<cc />" end
    assert_xml doc, "<cc/>"

    doc = Nokogiri::XML SOURCE
    doc.root.transform do |s| s.name != "xy" end
    assert_xml doc, "<bb/>"
  end
end
