class Hash
  alias :delete_single :delete
  
  def delete_multi(a0, *extras, &block)
    if extras.empty? || block_given?
      delete_single a0, *extras, &block
    else
      r = [ delete_single(a0) ]
      extras.each do |arg|
        r.push delete_single(arg)
      end
      r
    end
  end

  alias :delete :delete_multi
end
