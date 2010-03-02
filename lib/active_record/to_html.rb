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
