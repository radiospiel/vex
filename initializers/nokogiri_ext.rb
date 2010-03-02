require 'nokogiri'

class Nokogiri::XML::Node
  include NokogiriExt
end

class Nokogiri::XML::Document
  private :transform
end
