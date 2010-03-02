class Array
  include Array::ParallelMap
  include Array::Cross
  include Array::EachBatch

  def at_random
    self[Kernel.rand(length)] unless empty?
  end
end
