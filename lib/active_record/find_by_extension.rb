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

  def create_by!(args, opts, &block)
    args = opts.update(args) if opts
    obj = new args
    if block_given?
      yield(obj)
    end
    obj.save!
    obj
  end
  
  def find_or_create_by(args, opts = nil, &block)
    find(:first, :conditions => args) || create_by!(args, opts, &block)
  end

  def find_or_create_all_by(args, opts = nil, &block)
    requested = args.cross

    models = find_all_by(args)
    return models if requested.length == models.length

    # TODO: Check locking
    connection.locked("#{self.class.name}#create") do
      models = find_all_by(args)
      return models if requested.length == models.length

      keys = args.keys
      missing = requested - models.map do |model| 
        args.keys.inject({}) do |hash, key| hash.update key => model.send(key) end
      end

      # TODO: Potential mass insert, when no block given
      missing.each do |data|
        models << create_by!(data, opts, &block)
      end
    end
    
    models
  end
end

class ActiveRecord::Base
  extend ActiveRecord::FindByExtension
end
