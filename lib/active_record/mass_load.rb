module ActiveRecord::MassLoad
  class MissingAssociation
    include Singleton
    def target
      nil
    end
  end

  def mass_load_associations!(models, *associations)
    if defined?(Rails) && Rails.env.development? && models.detect { |rec| !rec.is_a?(self) }
      raise "Invalid models for mass_load_associations!"
    end

    return models if models.length < 2

    associations.flatten!

    models_by_id = models.inject({}) do |hash, model|
      hash.update model.id => model
    end
    ids = models_by_id.keys
    id_condition = ActiveRecord::MassLoad.get_id_condition(ids)

    associations = associations.collect do |association|
      case association
      when Hash then association.to_a.collect do |k,v| { k => v } end
      else association
      end
    end.flatten

    associations.each do |association|
      if association.is_a?(Hash)
        association = association.to_a.first
        other_assocs = association
        association = other_assocs.shift
      end

      varname = "@#{association}"

      base_assocs = []

      find(:all, :include => association, :conditions => id_condition).each do |model|
        target = models_by_id[model.id]
        proxy = model.instance_variable_get(varname)
        target.instance_variable_set(varname, proxy || MissingAssociation.instance)
        base_assocs << proxy if proxy
      end

      next if !other_assocs || other_assocs.empty?
      next if base_assocs.empty?

      base_assocs.flatten!

      base_assocs.first.class.mass_load_associations! base_assocs, *other_assocs
    end

    models
  end
  
  def self.get_id_condition(ids)
    id_condition = { :id => ids.sort }
  end
end

ActiveRecord::Base.extend ActiveRecord::MassLoad
