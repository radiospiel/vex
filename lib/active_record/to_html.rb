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

module ActiveRecord::ToHtml::Etest
  def test_to_html
    feed = Feed.create! :keyword => "test", :language => "language"

    html = <<HTML
<div class='feed'>
  <div class='data' nil="true"></div>
  <div class='id' type="integer">#{feed.id}</div>
  <div class='keyword'>test</div>
  <div class='language'>language</div>
</div>
HTML
    fhtml = feed.to_html :only => %w(data id keyword language)

    assert_equal(html, fhtml)
  end
end

