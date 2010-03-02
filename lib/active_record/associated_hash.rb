module ActiveRecord::AssociatedHash
  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    def self.default_options(name)
      { :class_name => name.to_s.singularize.camelize, :dependent => :destroy }
    end

    def associated_hash(name, opts)
      opts = ClassMethods.default_options(name).update(opts)

      ah_options = {
        :association => "associated_#{name}".to_sym,
        :keys => opts.delete(:keys),
        :values => opts.delete(:values)
      }

      has_many ah_options[:association], opts

      define_method(name) do
        instance_variable_get("@#{name}") ||
        instance_variable_set("@#{name}", Data.new(self, ah_options))
      end

      define_method("#{name}=") do |values|
        send(name).update(values)
      end
    end
  end
  
  class Data < BlankSlate
    def initialize(host, opts)
      @host = host

      @association = opts[:association] || missing_options!(:association)
      @keys = opts[:keys] || missing_options!(:keys)
      @values = opts[:values] || missing_options!(:values)
    end

    def to_hash    
      @hash ||= association.to_a.inject({}) do |hash, entry|
        hash.update key_for(entry) => value_for(entry)
      end
    end

    def update(u)
      @host.class.transaction do
        keys = to_hash.keys

        u.each { |k,v| self[k] = v }
        (keys - u.keys.map(&:to_s)).each do |k|
          self[k] = nil
        end
      end
    end

    def clear
      update({})
    end

    def []=(key, value)
      @hash = nil

      uo = associated_object(key)
      if !value then uo && association.delete(uo)
      elsif uo  then uo.update_attributes(@values => value)
      else           association.create!(@keys => key.to_s, @values => value)
      end
    end

    def [](key)
      value_for associated_object(key)
    end

    private

    def method_missing(sym, *args, &block)
      to_hash.send(sym, *args, &block)
    end

    def value_for(associated)
      associated && associated.send(@values)
    end

    def key_for(associated)
      associated && associated.send(@keys).to_sym
    end

    def associated_object(key)
      association.to_a.find { |obj| key_for(obj) == key.to_sym }
    end

    def association
      @host.send(@association)
    end
  end
end

