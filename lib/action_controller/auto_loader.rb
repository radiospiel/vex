module ActionController::AutoLoader
  def auto_load(*args)
    filter = Filter.new *args
    before_filter { |controller|
      filter.apply controller, controller.params
    }
  end

  class Filter
    attr :definition
    
    def initialize(*args)
      #
      # transform :feed, "comment", :c => "Klass" into
      #   { ;feed => "Feed", :comment => "Comment", :c => "Klass" }
      @definition = {}
      args.each do |arg|
        case arg
        when String, Symbol then @definition[arg.to_sym] = arg.to_s.gsub(/_id$/, "").camelize
        when Hash           then arg.each { |k,v| @definition[k.to_sym] = v }
        end
      end
    end
    
    def apply(target, params)
      @controller_name = target.respond_to?(:controller_name) && target.controller_name

      collect_params(params) do |var, klass, value|
        value = Integer(value) rescue value
        value = if value.is_a?(String) && klass.respond_to?(:[])
          klass[value]
        else
          klass.find(value)
        end

        target.instance_variable_set(var, value)
      end
      target
    end
    
    private
    
    def controller_klass
      @controller_name.camelize.constantize rescue nil
    end
    
    def load_klass!(key)
      key = key.to_sym
      klass = @definition[key]
      klass && klass.constantize
    end

    def load_klass(key)
      load_klass!(key) rescue nil
    end

    def collect_params(params)
      collect_params_(params) do |var, klass, value|
        yield var, klass, value if klass && value
      end
    end
    
    def collect_params_(params)
      #
      # collect attributes for search
      attrs = params.to_a.sort_by { |k,v| k.to_s }.
        each do |key, value|
          next unless value

          key = key.to_s
          if key.ends_with?("_id") 
            var = key[0...-3]
            value = value && Integer(value) rescue nil
          end

          yield "@#{var || key}", load_klass!(key), value
        end
      
      yield "@#{@controller_name}", controller_klass, (params["id"] && Integer(params["id"]) rescue nil)
      
      attrs
    end
  end
end

module ActionController::AutoLoader::Etest
  Filter = ActionController::AutoLoader::Filter
  
  def test_set_args
    x = Filter.new :feed, "comment", :c => "Comment"

    assert_equal({ :feed => "Feed", :comment => "Comment", :c => "Comment" }, 
      x.definition)
  end

  def setup
    Feed.stubs(:find).with(1).returns( "feed-1" )
    Feed.stubs(:find).with(2).returns( "feed-2" )
    Feed.stubs(:[]).with("1").returns( "feed-1" )
    Feed.stubs(:[]).with("2").returns( "feed-2" )
    Feed.stubs(:[]).with("one").returns( "feed-1" )
    Feed.stubs(:[]).with("two").returns( "feed-2" )

    @filter = Filter.new "feed", :p => "Feed"
  end
  
  def assert_filtered(exp, inp)
    assert_equal exp, @filter.apply(Object.new, inp).instance_variables_hash
  end
  
  def test_w_1
    assert_equal({ :feed => "Feed", :p => "Feed" }, @filter.definition)

    assert_filtered(({"@feed"=>"feed-1", "@p"=>"feed-2"}), :feed => "1", :p => "2")
    assert_filtered(({"@feed"=>"feed-1", "@p"=>"feed-2"}), :feed => "one", :p => "two")
  end

  def test_w_1_id
    @filter = Filter.new "feed_id", :p_id => "Feed"
    assert_equal({ :feed_id => "Feed", :p_id => "Feed" }, @filter.definition)

    @filter = Filter.new :feed_id, :p_id => "Feed"
    assert_equal({ :feed_id => "Feed", :p_id => "Feed" }, @filter.definition)

    assert_filtered(({"@feed"=>"feed-1", "@p"=>"feed-2"}), :feed_id => "1", :p_id => "2")
    assert_filtered(({"@feed"=>"feed-1"}), :feed_id => "1")
  end
end
