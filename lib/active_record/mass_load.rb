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

module ActiveRecord::MassLoad::Etest
  TEST_LIMIT = 10

  PROGRAMMES_TEST_EXPRESSIONS = %w(programme_group programme_group.user programme_group.company)
  
  def mass_load(programmes, mode)
    case mode
    when 1: Programme.mass_load_associations!(programmes, :programme_group)
    when 2: Programme.mass_load_associations!(programmes, :programme_group => [ { :user => :company } ])
    when 3: Programme.mass_load_associations!(programmes, :programme_group => [ :user ])
    when 4: Programme.mass_load_associations!(programmes, :programme_group)
    end
  end
  
  def programmes_for_test
    Programme.find :all, :limit => TEST_LIMIT, :conditions => "programme_group_id IS NOT NULL"
  end
  
  def test_correctness
    orig = programmes_for_test
    
    (1..4).each do |idx|
      progs = programmes_for_test
      mass_load progs, idx
      
      #assert_equal(progs, orig)
      assert_equal(progs.collect(&:id), orig.collect(&:id))
      
      PROGRAMMES_TEST_EXPRESSIONS.each do |expr|
        progs.zip(orig).each do |p, o|
          assert_equal eval("p.#{expr}"), eval("o.#{expr}")
        end
      end
    end
  end

=begin
  def selects_count
    old = Programme.connection.query_stats.detail["select"]
    yield
    Programme.connection.query_stats.detail["select"] - old
  end
  
  #
  # This test may fail in test mode. It only works ok with a real DB.
  def _test_speed_up
    #
    # Test that preloading actually brings down the # of queries
    PROGRAMMES_TEST_EXPRESSIONS.each do |expr|
      (1..4).each do |idx|
        orig_count = selects_count do
          progs = programmes_for_test
          progs.each do |p|
            eval("p.#{expr}")
          end
        end

        ml_count = selects_count do
          progs = programmes_for_test
          mass_load progs, idx
          progs.each do |p|
            eval("p.#{expr}")
          end
        end

        puts "#{orig_count} vs #{ml_count}"

        assert_gt orig_count, ml_count
      end
    end
  end  
=end

  def offers_for_test
    Offer.find(:all, :limit => TEST_LIMIT)
  end

  OFFERS_TEST_EXPRESSIONS = %w(programmes programme_group.user programme_group.company)
  
  def test_for_has_manies
    orig = offers_for_test
    offers = offers_for_test
    Offer.mass_load_associations! offers, :programmes => [ :programme_group ]

    assert_equal(orig, offers)

    orig.zip(offers).each do |a, b|
      assert_equal(a, b)
      assert_equal(a.programmes, b.programmes)
      a.programmes.zip(b.programmes).each do |ap, bp|
        assert_equal(ap, bp)
      end
    end
  end
end
