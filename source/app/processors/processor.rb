# frozen_string_literal: true

# Base methods for a processor
#
# processors have only one public class
# method, whcich, after execution,
# returns no instance of the class
module Processor
  extend ActiveSupport::Concern

  included do
    private_class_method :new

    def self.process(*args)
      new(*args).process
    end
  end

  def process
    raise 'Not implemented yet'
  end
end
