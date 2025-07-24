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

    def self.process(*args, **opts, &block)
      Rails.logger.debug("Running #{self}")
      new(*args, **opts, &block).process.tap do
        Rails.logger.debug("Finished running #{self}")
      end
    end
  end

  def process
    raise 'Not implemented yet'
  end
end
