class Processor
  private_class_method :new

  def self.process(*args)
    new(*args).process
  end

  def process
    fail "Not implemented yet"
  end
end
