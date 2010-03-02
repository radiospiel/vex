class Object
  include ObjectExt::MultipleAttributes
  include ObjectExt::WithBenchmark

  def originating(src, &block)
    yield
  rescue
    $!.instance_variable_set "@msg", "#{src}: #{$!}"
    def $!.to_s; @msg; end
    raise $!
  end
end
