module ActiveRecord::ToHtml
  def to_html(options = {}, &block)
    options = { 
      :skip_instruct => true, 
    }.update(options)
    
    to_xml(options, &block).gsub( /<[^>]+>/ ) do |m|
      if m.starts_with?("</")
        "</div>"
      else
        m =~ /^<(\S+)\s*([^>]*)>$/
        klass, args = $1, $2 
        "<div class='#{klass}'#{args.blank? ? "" : " #{args}"}>"
      end
    end
  end
end

class ActiveRecord::Base
  include ActiveRecord::ToHtml
end

module ActiveRecord::ToHtml::Etest
  class Data < ActiveRecord::Base
  end

  def setup
    Data.lite_table do
      string :name
      string :age
    end

    Data.create! :name => "name", :age => 2

    assert_equal(1, Data.count)
  end
  
  def teardown
    Data.destroy_all
  end
  
  def test_to_html
    html = <<-HTML
<div class='active-record-to-html-etest-data'>
  <div class='age'>2</div>
  <div class='id' type="integer">25</div>
  <div class='name'>name</div>
</div>
HTML

    assert_equal html, Data.first.to_html
  end
end
