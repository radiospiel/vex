require_dependency "xmlrpc/client"

class XMLRPC::AbstractClient < Hash
  with_mpx_logging "xmlrpc.log"
  
  attr :server
  attr :url

  def initialize(url, opts = {})
    @url = url
    @server = XMLRPC::Client.new2(url)
    update opts
    with_simple_access
  end

  alias :to_s :url
  
  protected

  class Namespace
    def initialize(client)
      @client = client
    end

    def self._;             :unused; end
    def self.unused(*args); :unused; end

    def self.method(m, *specs)
      opts = specs.extract_options!
      namespace = instance_variable_get "@namespace"
      
      define_method(m) do |*args|
        @client.send :server_call, "#{namespace}.#{m}", specs, args, opts
      end
    end
  end
  
  def self.namespace(name, &block)
    # This defines a new, anonymous Namespace class for this namespace. 
    # The class will have a  "@namespace" instance variable, which will
    # hold the namespace Besides of that the class needs nothing specific
    # besides what is defined in Namespace above already.
    #
    klass = Class.new(Namespace)
    klass.instance_variable_set "@namespace", name

    # yield bound to the new class object
    Proc.new.bind(klass).call

    define_method(name) do
      klass.new(self)
    end
  end
  
  private

  # does a server call.
  #
  # Parameters:
  #
  # - name       - the name of the XML-RPC method to call, usually includes a namespace,
  #        e.g. 'blogger.getRecentPosts'
  # - specs  - parameter specification, an array of 
  #     * :symbol   - a required parameter, which is taken from the args parameter
  #     * '$string' - a required parameter, which is taken from a method call
  # 
  def server_call(name, specs, args, opts)
    translated, logging = [], []
    
    # translate definition arguments into server call arguments
    specs.each do |arg|
      tr = case arg
      when :unused    then "unused"
      when Symbol     then args.shift || raise(ArgumentError, "Missing #{arg.inspect} argument")
      when /^\$(.+)$/ then self.send($1)
      else            raise ArgumentError, "invalid method definition #{arg.inspect}"
      end

      logging << (arg == "$password" ? "'********'" : tr.inspect)
      translated << tr
    end

    raise(ArgumentError, "Extra arguments to #{name}(..): #{args.inspect}") unless args.empty?

    logged("#{name}(#{logging.join(", ")})") do
      result = server.call(name, *translated)
      result = self.send(opts[:post], result) if opts[:post]
      result
    end
  end
end
