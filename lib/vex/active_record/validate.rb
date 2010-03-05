module ActiveRecord::Validate
  def self.all(quiet=nil, &block)
    klasses(quiet).inject(0) do |count, klass|
      count += invalid_models(klass, quiet).length
    end
  end

  def self.purge
    klasses(true).each do |klass|
      invalids = invalid_models(klass, true)
      klass.delete_all [ "id IN (?)", invalids.map(&:id) ] unless invalids.empty?
    end
  end
  
  
  def self.set_klass_for(opts)
    @klass_for_table ||= {}
    @klass_for_table.update opts.with_indifferent_access
  end
  
  private

  def self.klass_for_table(table)
    @klass_for_table ||= {}
    if klass = @klass_for_table[table]
      klass.constantize
    else
      table.singularize.camelize.constantize?
    end
  end
  
  def self.klasses(quiet)
    ActiveRecord::Base.connection.tables.map do |table|
      klass = klass_for_table table
      if !klass
        STDERR.puts "* #{table}: table w/o class" unless quiet
      elsif !klass.respond_to?(:table_name) || klass.table_name != table
        STDERR.puts "Tablename mismatch #{table.inspect} vs #{klass.table_name.inspect}" unless quiet
      else
        klass
      end
    end.compact
  end
  
  def self.invalid_models(klass, quiet)
    validate_klass(klass) do |*args|
      msg, force = *args
      STDERR.puts(msg) if force || !quiet
    end
  end
  
  def self.validate_klass(klass)
    yield "#{klass}: #{sum=klass.count} models"

    invalid = []

    klass.each do |model|
      next if model.valid?
      invalid << model
      
      yield "\tInvalid model #{model.class}##{model.id}: #{model.errors.full_messages.join(", ")}"
    end

    yield "\r#{klass}: checked #{klass.count} models, #{invalid.length} invalid", :force

    return invalid if invalid.empty?
    
    invalid.group_by(&:class).to_a.
      sort_by do |klass, ms| klass.name end.
      each do |klass, ms| 
        yield "\t** #{klass}: Invalid models: #{ms.collect(&:id).inspect}"
      end
    
    invalid
  end
end
