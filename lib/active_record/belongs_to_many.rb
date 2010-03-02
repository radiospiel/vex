# belongs_to_many gives you a behaviour that you would typically (and 
# for a reason) do via has_and_belongs_to_many or has_many. You would
# do this for performance reasons under a quite small set of circumstances:
#
# * your habtm code runs slow, because of the huge number of database
#   transactions involved
# * you will never search by the associated data
#
# In these cases belongs_to_many might help. It not only denormalizes the 
# database structure, it uses a single text column in the host table to 
# hold the referenced ids, and uses ActiveRecord's read_attribute and 
# write_attribute methods to automatically convert between IDs involved 
# and actual objects.
# 
# belongs_to_many has a number of limitations over AR' has_and_belongs_to_many
# and has_many associations:
#
# * it is not an association proxy: that means you cannot extend it, 
#   cannot search through it, etc.
# * The '<<' operator is not allowed and throws an exceptions: As
#   we wanted to stay pretty close to rails default behaviour we had
#   to disable that method. Otherwise all performance gain would be
#   lost anyways.
# * You cannot search via the associated data, because there is no
#   easy way to join the associated tables.
# * There might be a bogus write when setting the column
#   
# ONCE MORE! THIS IS NOT A MORE PERFORMANT replacement for
# has_and_belongs_to_many or has_many!
#
module BelongsToMany
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    #
    # define a belongs_to_many pseudo-association. 
    # Supported options:
    #
    # :class_name .. The name of the class that is referenced
    # :supersedes .. code to roll out the old behaviour. This is needed
    #    for the model to survive migrations and to semi-automatically
    #    migrate the data.
    #
    # Example:
=begin
    belongs_to_many :havings,
      :supersedes => lambda { |name|
        has_and_belongs_to_many name, :join_table => :belongings_havings, :class_name => "Having"
      }
=end
    #
    def belongs_to_many(name, opts = {})
      s = name.to_s.singularize
      ids_name = "#{s}_ids"
      
      if supersedes = opts.delete(:supersedes)
        # if the belongs_to_many column exists we instanciate the superseded
        # association with the name + "_superseded" and build the belongs_to_many 
        # association; if not, we only build the old association with the 
        # current name.
        #
        
        if column_names.include?(ids_name)
          supersedes.call("#{name}_superseded")
          belongs_to_many(name, opts)
        else
          supersedes.call(name)
        end

        return
      end
      
      #
      class_name = opts[:class_name] || s.camelize.constantize

      self.class_eval code = <<RUBY
      def #{name}
        #{class_name}.find(#{ids_name}).freeze
      end

      def #{name}=(array)
        self.#{ids_name} = array.collect(&:id).uniq
        save! unless new_record?
      end

      def #{ids_name}
        read_attribute(:#{ids_name}).to_s.split(/[^0-9]+/).reject(&:blank?).collect { |s| Integer(s) }
      end

      def #{ids_name}=(array)
        write_attribute(:#{ids_name}, array.empty? ? nil : "/" + array.join("/") + "/")
      end
RUBY
    end
  end

  module Migrations
    #
    # e.g. 
    # 
    #  migrate_belongs_to_many(:old_belongings => :belongings)
    #
    def migrate(klass, up_or_down, *assocs)
      klass.reset_column_information

      case up_or_down
      when :down  then assocs.map! { |assoc| [ "#{assoc}", "#{assoc}_superseded" ] }
      when :up    then assocs.map! { |assoc| [ "#{assoc}_superseded", "#{assoc}" ] }
      end
      
      klass.all.with_progress.each do |model|
        assocs.each do |from, to|
          model.send "#{to}=", model.send(from)
        end

        # Try to save. Warn, if that fails.
        unless model.save
          STDERR.puts "#{model.class}##{model.id}: #{errors.full_messages.join(", ")}"
          model.save_without_validation
        end

        # verify migration...

        new_model = klass.find(model.id)

        assocs.each do |from, to|
          next if new_model.send(to) == model.send(from)
          STDERR.puts "#{model.class}##{model.id}: Mismatch on ##{from.inspect} -> #{to.inspect}" 
        end

        self
      end
    end
  end

  extend Migrations
end
