class Object
  def instance_variables_hash(opts = :genuine)
    instance_variables.inject({}) do |hash, var| 
      key = opts == :symbol_keys ? var[1..-1].to_sym : var
      hash.update key => instance_variable_get(var)
    end
  end
end
