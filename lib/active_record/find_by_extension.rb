module ActiveRecord::FindByExtension
  def find_all_by(args, opts = nil)
    return find(:all, :conditions => args) if opts.nil?

    with_scope(:find => opts) do find_all_by(args) end
  end

  def find_by(args, opts = nil)
    return find(:first, :conditions => args) if opts.nil?

    with_scope(:find => opts) do find_by(args) end
  end

  def find_by!(args, opts = nil)
    find_by(args, opts) || 
      raise(ActiveRecord::RecordNotFound, "Couldn't find #{self} with #{args.inspect}")
  end
end

class ActiveRecord::Base
  extend ActiveRecord::FindByExtension
end
