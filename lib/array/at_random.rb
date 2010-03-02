class Array
  def at_random
    self[Kernel.rand(length)] unless empty?
  end
end
