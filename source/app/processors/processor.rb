# frozen_string_literal: true

class Processor
  private_class_method :new

  def self.process(*args)
    new(*args).process
  end

  def process
    raise 'Not implemented yet'
  end
end
