class Module
  def etest(*args)
    self.reload if respond_to?(:reload)
    EmbeddedTest.run self, *args
  end
end

